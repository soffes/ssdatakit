//
//  SSManagedObject.m
//  SSDataKit
//
//  Created by Sam Soffes on 10/23/11.
//  Copyright (c) 2011-2014 Sam Soffes. All rights reserved.
//

#import "SSManagedObject.h"

NSString *const kSSManagedObjectWillResetNotificationName = @"SSManagedObjectWillResetNotification";

static id __contextSaveObserver = nil;
static NSManagedObjectContext *__privateQueueContext = nil;
static NSManagedObjectContext *__mainQueueContext = nil;
static NSManagedObjectModel *__managedObjectModel = nil;
static NSURL *__persistentStoreURL = nil;
static NSString *__persistentStoreType = nil;
static NSDictionary *__persistentStoreOptions = nil;
static BOOL __automaticallyResetsPersistentStore = NO;
static NSString *const kURIRepresentationKey = @"URIRepresentation";

@implementation SSManagedObject

#pragma mark - Managing application contexts

+ (NSManagedObjectContext *)privateQueueContext {
	if (!__privateQueueContext) {
		__privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		[__privateQueueContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
        __contextSaveObserver = [[NSNotificationCenter defaultCenter]
         addObserverForName:NSManagedObjectContextDidSaveNotification
         object:nil
         queue:nil
         usingBlock:^(NSNotification *note) {
             NSManagedObjectContext *savingContext = [note object];
             if ([savingContext parentContext] == [self privateQueueContext]) {
                 [__privateQueueContext performBlock:^{
                     [__privateQueueContext save:nil];
                 }];
             }
         }];
	}
	return __privateQueueContext;
}


+ (BOOL)hasPrivateQueueContext {
    return (__privateQueueContext != nil);
}


+ (NSManagedObjectContext *)mainQueueContext {
	if (!__mainQueueContext) {
		__mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[__mainQueueContext setParentContext:[self privateQueueContext]];
	}
	return __mainQueueContext;
}


+ (BOOL)hasMainQueueContext {
	return (__mainQueueContext != nil);
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
+ (NSManagedObjectContext *)mainContext {
	return [self mainQueueContext];
}
#pragma clang diagnostic pop


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
+ (BOOL)hasMainContext {
	return [self hasMainQueueContext];
}
#pragma clang diagnostic pop


+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSManagedObjectModel *model = [self managedObjectModel];
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

		NSURL *url = [self persistentStoreURL];
		NSError *error = nil;
		NSDictionary *storeOptions = [self persistentStoreOptions];
		[persistentStoreCoordinator addPersistentStoreWithType:[self persistentStoreType] configuration:nil URL:url options:storeOptions error:&error];

		if (error) {
			// Reset the persistent store
			BOOL missingError = error.code == NSMigrationMissingSourceModelError || error.code == NSMigrationMissingMappingModelError;
			if (__automaticallyResetsPersistentStore && missingError) {
				[SSManagedObject removeSQLiteFiles];
				[persistentStoreCoordinator addPersistentStoreWithType:[self persistentStoreType] configuration:nil URL:url options:storeOptions error:&error];
			} else {
				NSLog(@"[SSDataKit] Failed to add persistent store: %@ %@", error, error.userInfo);
			}
		}
	});

	return persistentStoreCoordinator;
}


+ (NSDictionary *)persistentStoreOptions {
	if (!__persistentStoreOptions) {
		[self setPersistentStoreOptions:[NSDictionary dictionaryWithObjectsAndKeys:
										 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
										 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
										 nil]];
	}
	return __persistentStoreOptions;
}


+ (void)setPersistentStoreOptions:(NSDictionary *)options {
	__persistentStoreOptions = options;
}


+ (NSManagedObjectModel *)managedObjectModel {
	if (!__managedObjectModel) {
		// Default model
		NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];

		// Ensure a model is loaded
		if (!model) {
			[[NSException exceptionWithName:@"SSManagedObjectMissingModel" reason:@"You need to provide a managed model." userInfo:nil] raise];
			return nil;
		}

		[self setManagedObjectModel:model];
	}
	return __managedObjectModel;
}


+ (void)setManagedObjectModel:(NSManagedObjectModel *)model {
	__managedObjectModel = model;
}


+ (NSURL *)persistentStoreURL {
	if (!__persistentStoreURL) {
		NSDictionary *applicationInfo = [[NSBundle mainBundle] infoDictionary];
#if TARGET_OS_IPHONE
		NSString *applicationName = [applicationInfo objectForKey:@"CFBundleDisplayName"];
		NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
		NSURL *url = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", applicationName]];
#else
		NSString *applicationName = [applicationInfo objectForKey:@"CFBundleName"];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSURL *applicationSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
		applicationSupportURL = [applicationSupportURL URLByAppendingPathComponent:applicationName];

		NSDictionary *properties = [applicationSupportURL resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:nil];
		if (!properties) {
			[fileManager createDirectoryAtPath:[applicationSupportURL path] withIntermediateDirectories:YES attributes:nil error:nil];
		}

		NSURL *url = [applicationSupportURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", applicationName]];
#endif
		[self setPersistentStoreURL:url];
	}
	return __persistentStoreURL;
}


+ (void)setPersistentStoreURL:(NSURL *)url {
	__persistentStoreURL = url;
}


+ (NSString *)persistentStoreType {
	return __persistentStoreType ? __persistentStoreType : NSSQLiteStoreType;
}


+ (void)setPersistentStoreType:(NSString *)persistentStoreType {
	__persistentStoreType = persistentStoreType;
}


#pragma mark - Resetting the Presistent Store

+ (void)resetPersistentStore {
	// Post will reset notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kSSManagedObjectWillResetNotificationName object:nil userInfo:nil];

	// Destroy old contexts
	[[NSNotificationCenter defaultCenter] removeObserver:__contextSaveObserver];
	[__mainQueueContext reset];
	__mainQueueContext = nil;

	[__privateQueueContext reset];
	__privateQueueContext = nil;

	// Delete old persistent store
	NSURL *url = [self persistentStoreURL];
	NSPersistentStoreCoordinator *psc = [SSManagedObject persistentStoreCoordinator];
	if ([psc removePersistentStore:psc.persistentStores.lastObject error:nil]) {
		[SSManagedObject removeSQLiteFiles];

		// Make a new one
		[psc addPersistentStoreWithType:[self persistentStoreType] configuration:nil URL:url options:[SSManagedObject persistentStoreOptions] error:nil];
	}
}


+ (void)setAutomaticallyResetsPersistentStore:(BOOL)automaticallyReset {
	__automaticallyResetsPersistentStore = automaticallyReset;
}


+ (BOOL)automaticallyResetsPersistentStore {
	return __automaticallyResetsPersistentStore;
}

+ (void)removeSQLiteFiles {
	[[NSNotificationCenter defaultCenter] postNotificationName:kSSManagedObjectWillResetNotificationName object:nil userInfo:nil];
	NSURL *sqliteURL = [SSManagedObject persistentStoreURL];
	NSURL *baseURL = [sqliteURL URLByDeletingLastPathComponent];
	NSString *dbFilenameString = [sqliteURL lastPathComponent];

	NSURL *sharedMemoryURL = [baseURL URLByAppendingPathComponent:[dbFilenameString stringByAppendingString:@"-shm"]];
	NSURL *writeAheadLogURL = [baseURL URLByAppendingPathComponent:[dbFilenameString stringByAppendingString:@"-wal"]];

	[[NSFileManager defaultManager] removeItemAtURL:sqliteURL error:nil];
	[[NSFileManager defaultManager] removeItemAtURL:sharedMemoryURL error:nil];
	[[NSFileManager defaultManager] removeItemAtURL:writeAheadLogURL error:nil];
}


#pragma mark - Getting Entity Information

+ (NSString *)entityName {
	return NSStringFromClass(self);
}


+ (NSEntityDescription *)entity {
	return [self entityWithContext:nil];
}


+ (NSEntityDescription *)entityWithContext:(NSManagedObjectContext *)context {
	if (!context) {
		context = [self mainQueueContext];
	}

	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}


+ (NSArray *)defaultSortDescriptors {
	// Subclasses should override this
	return nil;
}


#pragma mark - NSObject

- (id)init {
	return [self initWithContext:nil];
}


#pragma mark - Initializing

- (id)initWithContext:(NSManagedObjectContext *)context {
	if (!context) {
		context = [[self class] mainQueueContext];
	}

	NSEntityDescription *entity = [[self class] entityWithContext:context];

	return (self = [self initWithEntity:entity insertIntoManagedObjectContext:context]);
}


#pragma mark - Object IDs

- (NSManagedObjectID *)permanentObjectID {
	if ([[self objectID] isTemporaryID]) {
		[[self managedObjectContext] obtainPermanentIDsForObjects:@[ self ] error:nil];
	}
	return [self objectID];
}


#pragma mark - Reflection

- (NSArray *)attributeKeys {
	return [[[[self class] entityWithContext:[self managedObjectContext]] attributesByName] allKeys];
}


- (NSArray *)persistedAttributeKeys {
	NSDictionary *attributes = [[[self class] entityWithContext:[self managedObjectContext]] attributesByName];
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	for (NSString *key in attributes) {
		if ([[attributes objectForKey:key] isTransient] == NO) {
			[keys addObject:key];
		}
	}

	return keys;
}


- (NSArray *)transientAttributeKeys {
	NSDictionary *attributes = [[[self class] entityWithContext:[self managedObjectContext]] attributesByName];
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	for (NSString *key in attributes) {
		if ([[attributes objectForKey:key] isTransient] == YES) {
			[keys addObject:key];
		}
	}

	return keys;
}


- (NSArray *)relationshipKeys {
	return [[[[self class] entityWithContext:[self managedObjectContext]] relationshipsByName] allKeys];
}


- (NSRelationshipDescription *)relationshipForKeyPath:(NSString *)keyPath {
	// Find releationship
	NSArray *keys = [keyPath componentsSeparatedByString:@"."];

	// We need keys to find the relationship
	if ([keys count] == 0) {
		return nil;
	}

	NSEntityDescription *rootEntity = [[self class] entityWithContext:[self managedObjectContext]];
	NSRelationshipDescription *relationship = nil;

	// Loop through keys and find the relationship
	for (NSString *key in keys) {
		if (relationship) {
			rootEntity = [relationship destinationEntity];
		}

		relationship = [[rootEntity relationshipsByName] objectForKey:key];
	}

	return relationship;
}


#pragma mark - Manipulation

- (BOOL)save {
	return [self.managedObjectContext save:nil];
}


- (void)delete {
	[self.managedObjectContext deleteObject:self];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	NSManagedObjectContext *context = [[self class] mainQueueContext];
	NSPersistentStoreCoordinator *psc = [[self class] persistentStoreCoordinator];
	self = (SSManagedObject *)[context objectWithID:[psc managedObjectIDForURIRepresentation:(NSURL *)[decoder decodeObjectForKey:kURIRepresentationKey]]];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[[self permanentObjectID] URIRepresentation] forKey:kURIRepresentationKey];
}


@end

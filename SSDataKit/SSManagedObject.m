//
//  SSManagedObject.m
//  SSDataKit
//
//  Created by Sam Soffes on 10/23/11.
//  Copyright (c) 2011-2013 Sam Soffes. All rights reserved.
//

#import "SSManagedObject.h"

static NSMutableDictionary *__storeConfigurations = nil;
static id __contextSaveObserver = nil;
static NSManagedObjectContext *__privateQueueContext = nil;
static NSManagedObjectContext *__mainQueueContext = nil;
static NSManagedObjectModel *__managedObjectModel = nil;
static BOOL __automaticallyResetsPersistentStore = NO;

static NSString *const kURIRepresentationKey = @"URIRepresentation";
static NSString *const kStoreURLKey = @"StoreURL";
static NSString *const kStoreOptionsKey = @"StoreOptions";
static NSString *const kStoreTypeKey = @"StoreType";

@implementation SSManagedObject

#pragma mark - Initialization

+ (void)initialize {
	if (self == [SSManagedObject class]) {
		__storeConfigurations = [NSMutableDictionary dictionary];
		[self
		 setPersistentStoreOptions:[self defaultPersistentStoreOptions]
		 type:[self defaultPersistentStoreType]
		 URL:[self defaultPersistentStoreURL]
		 forConfiguration:nil];
	}
}


#pragma mark - Managing application contexts

+ (void)accessContextsInBlock:(void (^) (void))block {
	NSParameterAssert(block != nil);
	
	static dispatch_queue_t queue = NULL;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = dispatch_queue_create("co.seesaw.whatever", DISPATCH_QUEUE_SERIAL);
	});
	
	dispatch_sync(queue, block);
}


+ (NSManagedObjectContext *)privateQueueContext_NonBlocking {
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


+ (NSManagedObjectContext *)privateQueueContext {
	__block NSManagedObjectContext *context = nil;
	[self accessContextsInBlock:^{
		context = [self privateQueueContext_NonBlocking];
	}];
	return context;
}


+ (BOOL)hasPrivateQueueContext {
	__block BOOL hasContext = NO;
	[self accessContextsInBlock:^{
		hasContext = (__privateQueueContext != nil);
	}];
	return hasContext;
}


+ (NSManagedObjectContext *)mainQueueContext {
	[self accessContextsInBlock:^{
		if (!__mainQueueContext) {
			__mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
			[__mainQueueContext setParentContext:[self privateQueueContext_NonBlocking]];
		}
	}];
	return __mainQueueContext;
}


+ (BOOL)hasMainQueueContext {
	__block BOOL hasContext = NO;
	[self accessContextsInBlock:^{
		hasContext = (__mainQueueContext != nil);
	}];
	return hasContext;
}


+ (NSManagedObjectContext *)mainContext {
	return [self mainQueueContext];
}


+ (BOOL)hasMainContext {
	return [self hasMainQueueContext];
}


#pragma mark - Working with the persistent store

+ (NSURL *)defaultPersistentStoreURL {
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
	return url;
}


+ (NSDictionary *)defaultPersistentStoreOptions {
	return @{
		NSMigratePersistentStoresAutomaticallyOption : @YES,
		NSInferMappingModelAutomaticallyOption : @YES
	};
}


+ (NSString *)defaultPersistentStoreType {
	return NSSQLiteStoreType;
}


+ (void)setPersistentStoreOptions:(NSDictionary *)options
							 type:(NSString *)type
							  URL:(NSURL *)URL
				 forConfiguration:(NSString *)configuration {
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	if (options) { settings[kStoreOptionsKey] = options; }
	if (URL) { settings[kStoreURLKey] = URL; }
	if (type) { settings[kStoreTypeKey] = type; }
	__storeConfigurations[configuration ?: [NSNull null]] = settings;
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


+ (void)addStoreForConfiguration:(NSString *)configuration toCoordinator:(NSPersistentStoreCoordinator *)coordinator {
	NSError *error = nil;
	NSDictionary *settings = __storeConfigurations[configuration ?: [NSNull null]];
	NSURL *URL = settings[kStoreURLKey];
	NSString *type = settings[kStoreTypeKey];
	NSDictionary *options = settings[kStoreOptionsKey];
	[coordinator addPersistentStoreWithType:type configuration:configuration URL:URL options:options error:&error];
	if (error) {
		if (__automaticallyResetsPersistentStore && error.code == 134130) {
			[[NSFileManager defaultManager] removeItemAtURL:URL error:nil];
			[coordinator addPersistentStoreWithType:type configuration:configuration URL:URL options:options error:&error];
		}
		else {
			NSLog(@"[SSDataKit] Failed to add persistent store: %@ %@", error, [error userInfo]);
		}
	}
}


+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	static NSPersistentStoreCoordinator *coordinator = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		NSManagedObjectModel *model = [self managedObjectModel];
		coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		[__storeConfigurations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			id configuration = nil;
			if ([key isKindOfClass:[NSString class]]) {
				configuration = key;
			}
			[self addStoreForConfiguration:configuration toCoordinator:coordinator];
		}];
	});
	return coordinator;
}


#pragma mark - Resetting the Presistent Store

+ (void)resetPersistentStore {
	[self accessContextsInBlock:^{
		
		// unwind old contexts
		[[NSNotificationCenter defaultCenter] removeObserver:__contextSaveObserver];
		[__mainQueueContext reset];
		__mainQueueContext = nil;
		[__privateQueueContext reset];
		__privateQueueContext = nil;
		
		// blow away stores
		NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
		NSFileManager *manager = [NSFileManager defaultManager];
		for (NSPersistentStore *store in [coordinator persistentStores]) {
			NSURL *URL = [store URL];
			NSString *configuration = [store configurationName];
			if ([coordinator removePersistentStore:store error:nil]) {
				[manager removeItemAtURL:URL error:nil];
				[self addStoreForConfiguration:configuration toCoordinator:coordinator];
			}
		}
		
	}];
}


+ (void)setAutomaticallyResetsPersistentStore:(BOOL)automaticallyReset {
	__automaticallyResetsPersistentStore = automaticallyReset;
}


+ (BOOL)automaticallyResetsPersistentStore {
	return __automaticallyResetsPersistentStore;
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

- (void)save {
	[self.managedObjectContext save:nil];
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

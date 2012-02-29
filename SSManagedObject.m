//
//  SSManagedObject.m
//  SSDataKit
//
//  Created by Sam Soffes on 10/23/11.
//  Copyright (c) 2011 Sam Soffes. All rights reserved.
//

#import "SSManagedObject.h"
#import "SSManagedObjectContext.h"

static NSManagedObjectModel *kManagedObjectModel = nil;
static NSURL *kPersistentStoreURL = nil;
static NSString *const kURIRepresentationKey = @"URIRepresentation";

@implementation SSManagedObject

#pragma mark - Managing Main Context

+ (SSManagedObjectContext *)mainContext {
	static SSManagedObjectContext *mainContext = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		mainContext = [[SSManagedObjectContext alloc] init];
		mainContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
	});
	
	return mainContext;
}


+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
		NSManagedObjectModel *model = [self managedObjectModel];
		
		// Default to merged model if there isn't one
		if (!model) {
			model = [NSManagedObjectModel mergedModelFromBundles:nil];
			
			// Set the model if that's the model we end up using
			if (model) {
				[self setManagedObjectModel:model];
			} else {
				[[NSException exceptionWithName:@"SSManagedObjectMissingModel" reason:@"You need to provide a managed model." userInfo:nil] raise];
			}
		}
		
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		
		NSURL *url = [self persistentStoreURL];
		if (!url) {
			NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
			url = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", applicationName]];
		}
		
		NSError *error = nil;
		NSDictionary *storeOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		[persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:storeOptions error:&error];
	});
	
	return persistentStoreCoordinator;
}


+ (NSManagedObjectModel *)managedObjectModel {
	return kManagedObjectModel;
}


+ (void)setManagedObjectModel:(NSManagedObjectModel *)model {
	[model retain];
	[kManagedObjectModel release];
	kManagedObjectModel = model;
}


+ (NSURL *)persistentStoreURL {
	return kPersistentStoreURL;
}


+ (void)setPersistentStoreURL:(NSURL *)url {
	[url retain];
	[kPersistentStoreURL release];
	kPersistentStoreURL = url;
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
		context = [self mainContext];
	}
	
	return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}


#pragma mark - NSObject

- (id)init {
	return [self initWithContext:nil];
}


#pragma mark - Initializing

- (id)initWithContext:(NSManagedObjectContext *)context {
	if (!context) {
		context = [[self class] mainContext];
	}
	
	NSEntityDescription *entity = [[self class] entityWithContext:context];
	
	return (self = [self initWithEntity:entity insertIntoManagedObjectContext:context]);
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
	
	return [keys autorelease];
}


- (NSArray *)transientAttributeKeys {
	NSDictionary *attributes = [[[self class] entityWithContext:[self managedObjectContext]] attributesByName];
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	for (NSString *key in attributes) {
		if ([[attributes objectForKey:key] isTransient] == YES) {
			[keys addObject:key];
		}
	}
	
	return [keys autorelease];
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

- (void)delete {
	[[self managedObjectContext] deleteObject:self];
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	NSManagedObjectContext *context = [[self class] mainContext];
	NSPersistentStoreCoordinator *psc = [[self class] persistentStoreCoordinator];
	self = (SSManagedObject *)[[context objectWithID:[psc managedObjectIDForURIRepresentation:(NSURL *)[decoder decodeObjectForKey:kURIRepresentationKey]]] retain];
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[[self objectID] URIRepresentation] forKey:kURIRepresentationKey];
}


@end

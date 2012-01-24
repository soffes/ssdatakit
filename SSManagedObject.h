//
//  SSManagedObject.h
//  SSDataKit
//
//  Created by Sam Soffes on 10/23/11.
//  Copyright (c) 2011 Sam Soffes. All rights reserved.
//

typedef enum {
	SSManagedObjectStateUnknown  = 0,
	
	SSManagedObjectStateInserted = 1 << 0,
	SSManagedObjectStateUpdated  = 1 << 1,
	SSManagedObjectStateDeleted  = 1 << 2,
	
	SSManagedObjectStateSaving   = 1 << 3,
	SSManagedObjectStateSaved    = 1 << 4
} SSManagedObjectState;

@class SSManagedObjectContext;

@interface SSManagedObject : NSManagedObject <NSCoding>

// Accessing the Main Context
+ (SSManagedObjectContext *)mainContext;

// Configuring the Persistent Store
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSManagedObjectModel *)managedObjectModel;
+ (void)setManagedObjectModel:(NSManagedObjectModel *)model;
+ (NSURL *)persistentStoreURL;
+ (void)setPersistentStoreURL:(NSURL *)url;

// Getting Entity Information
+ (NSString *)entityName;
+ (NSEntityDescription *)entityDescription;
+ (NSEntityDescription *)entityDescriptionWithContext:(NSManagedObjectContext *)context;

// Initializing
- (id)initWithContext:(NSManagedObjectContext *)context;

// Reflection
- (NSArray *)attributeKeys;
- (NSArray *)persistedAttributeKeys;
- (NSArray *)transientAttributeKeys;
- (NSArray *)relationshipKeys;
- (NSRelationshipDescription *)relationshipForKeyPath:(NSString *)keyPath;

// Manipulation
- (void)delete;

@end

//
//  SSManagedObject.h
//  SSDataKit
//
//  Created by Sam Soffes on 10/23/11.
//  Copyright (c) 2011 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SSManagedObject : NSManagedObject <NSCoding>

// Accessing the Main Context
+ (NSManagedObjectContext *)mainContext;
+ (BOOL)hasMainContext;

// Configuring the Persistent Store
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSDictionary *)persistentStoreOptions;
+ (void)setPersistentStoreOptions:(NSDictionary *)options;
+ (NSManagedObjectModel *)managedObjectModel;
+ (void)setManagedObjectModel:(NSManagedObjectModel *)model;
+ (NSURL *)persistentStoreURL;
+ (void)setPersistentStoreURL:(NSURL *)url;

// Getting Entity Information
+ (NSString *)entityName;
+ (NSEntityDescription *)entity;
+ (NSEntityDescription *)entityWithContext:(NSManagedObjectContext *)context;
+ (NSArray *)defaultSortDescriptors;

// Initializing
- (id)initWithContext:(NSManagedObjectContext *)context;

// Reflection
- (NSArray *)attributeKeys;
- (NSArray *)persistedAttributeKeys;
- (NSArray *)transientAttributeKeys;
- (NSArray *)relationshipKeys;
- (NSRelationshipDescription *)relationshipForKeyPath:(NSString *)keyPath;

// Manipulation
- (void)save;
- (void)delete;

// Resetting
+ (void)resetPersistentStore;

@end

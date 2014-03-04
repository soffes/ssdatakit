//
//  SSManagedObject.h
//  SSDataKit
//
//  Created by Sam Soffes on 10/23/11.
//  Copyright (c) 2011-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const kSSManagedObjectWillResetNotificationName;

@interface SSManagedObject : NSManagedObject <NSCoding>

#pragma mark - Accessing the application contexts

/**
 Created as the "root" managed object context. This context has no parent
 and instead has the `persistentStoreCoordinator` set. Use this to perform
 any background processing in your Core Data stack. Make sure to pull data into
 descendant contexts if you save directly here.

 Changes saved to any direct descendants of this context are automatically
 pulled up and saved to the persistent store.
 */
+ (NSManagedObjectContext *)privateQueueContext;
+ (BOOL)hasPrivateQueueContext;

/**
Created as a child of the `privateQueueContext`. Use this context on the main
thread or to update your interface.

Changes saved here are automatically reflected in the `privateQueueContext`.
 */
+ (NSManagedObjectContext *)mainQueueContext;
+ (BOOL)hasMainQueueContext;


/**
 Synonymous with the `mainQueueContext` methods.
 */
+ (NSManagedObjectContext *)mainContext DEPRECATED_ATTRIBUTE;
+ (BOOL)hasMainContext DEPRECATED_ATTRIBUTE;


#pragma mark - Configuring the Persistent Store

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSDictionary *)persistentStoreOptions;
+ (void)setPersistentStoreOptions:(NSDictionary *)options;
+ (NSManagedObjectModel *)managedObjectModel;
+ (void)setManagedObjectModel:(NSManagedObjectModel *)model;
+ (NSURL *)persistentStoreURL;
+ (void)setPersistentStoreURL:(NSURL *)url;
+ (NSString *)persistentStoreType;
+ (void)setPersistentStoreType:(NSString *)persistentStoreType;


#pragma mark - Resetting the Presistent Store

+ (void)resetPersistentStore;

/**
 By default, this is NO. If you set this to YES, it will automatically delete the persistent store file and make a new
 one if it fails to initialize (i.e. you failed to add a migration). This is super handy for development. You must set
 this before calling `persistentStoreCoordinator` or anything that calls it like `mainContext`.
 */
+ (void)setAutomaticallyResetsPersistentStore:(BOOL)automaticallyReset;
+ (BOOL)automaticallyResetsPersistentStore;


#pragma mark -  Getting Entity Information

+ (NSString *)entityName;
+ (NSEntityDescription *)entity;
+ (NSEntityDescription *)entityWithContext:(NSManagedObjectContext *)context;
+ (NSArray *)defaultSortDescriptors;


#pragma mark -  Initializing

- (instancetype)initWithContext:(NSManagedObjectContext *)context;


#pragma mark - Object ID resolution

- (NSManagedObjectID *)permanentObjectID;


#pragma mark -  Reflection

- (NSArray *)attributeKeys;
- (NSArray *)persistedAttributeKeys;
- (NSArray *)transientAttributeKeys;
- (NSArray *)relationshipKeys;
- (NSRelationshipDescription *)relationshipForKeyPath:(NSString *)keyPath;


#pragma mark -  Manipulation

- (BOOL)save;
- (void)delete;

@end

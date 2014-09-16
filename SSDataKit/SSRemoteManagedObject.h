//
//  SSRemoteManagedObject.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSManagedObject.h"

@interface SSRemoteManagedObject : SSManagedObject

///-------------------------
/// @name Default Properties
///-------------------------

/**
 This attribute is required! You must add an attribute named `remoteID` to your data model if you want to use
 SSRemoteManagedObject with it. It can be any type.
 */
@property (nonatomic) id remoteID;

/**
 Optional attribute.
 */
@property (nonatomic) NSDate *createdAt;

/**
 Optional attribute.
 */
@property (nonatomic) NSDate *updatedAt;


///--------------------
/// @name Configuration
///--------------------

/**
 Key in remote dictionary for the object's remoteID attribute.

 The default is `id`.

 @return The key of the remote ID attribute.
 */
+ (NSString *)remoteIDDictionaryKey;


///---------------------
/// @name Find or Create
///---------------------

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. The object will be created if it is not found. The `mainQueueContext` will be used.

 @param remoteID The remote ID of the object.
 @return An existing object with the given remote ID or a new object with the remoteID set.
 */
+ (instancetype)objectWithRemoteID:(id)remoteID;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. The object will be created if it is not found.

 @param remoteID The remote ID of the object.
 @param context The context to use.
 @return An existing object with the given remote ID or a new object with the remoteID set.
 */
+ (instancetype)objectWithRemoteID:(id)remoteID context:(NSManagedObjectContext *)context;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. `nil` is returned if the object is not found. The `mainQueueContext` will be used.

 @param remoteID The remote ID of the object.
 @return An existing object with the given remote ID.
 */
+ (instancetype)existingObjectWithRemoteID:(id)remoteID;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. `nil` is returned if the object is not found.

 @param remoteID The remote ID of the object.
 @param context The context to use.
 @return An existing object with the given remote ID.
 */
+ (instancetype)existingObjectWithRemoteID:(id)remoteID context:(NSManagedObjectContext *)context;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. The object will be created if it is not found. The `mainQueueContext` will be used.

 The dictionary will be unpacked if `shouldUnpackDictionary:` returns `YES`. The remote ID will be extracted from the
 dictionary using `remoteIDDictionaryKey`.

 @param dictionary The dictionary to unpack.
 @return An existing object with the given dictionary or a new object with the dictionary unpacked.
 */
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. The object will be created if it is not found.

 The dictionary will be unpacked if `shouldUnpackDictionary:` returns `YES`. The remote ID will be extracted from the
 dictionary using `remoteIDDictionaryKey`.

 @param dictionary The dictionary to unpack.
 @param context The context to use.
 @return An existing object with the given dictionary or a new object with the dictionary unpacked.
 */
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. `nil` is returned if the object is not found. If a context is not specified, the `mainContext`
 will be used.

 The dictionary will be unpacked if `shouldUnpackDictionary:` returns `YES` and there is an object with the given ID.
 The remote ID will be extracted from the dictionary using `remoteIDDictionaryKey`.

 @param dictionary The dictionary to unpack.
 @return An existing object with the given dictionary.
 */
+ (instancetype)existingObjectWithDictionary:(NSDictionary *)dictionary;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. `nil` is returned if the object is not found. If a context is not specified, the `mainContext`
 will be used.

 The dictionary will be unpacked if `shouldUnpackDictionary:` returns `YES` and there is an object with the given ID.
 The remote ID will be extracted from the dictionary using `remoteIDDictionaryKey`.

 @param dictionary The dictionary to unpack.
 @param context The context to use.
 @return An existing object with the given dictionary.
 */
+ (instancetype)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;


///----------------
/// @name Unpacking
///----------------

/**
 Map the attributes of the dictionary onto the properties of the object. The default implementation just unpacks
 `createdAt` and `updateAt`. You should override this, call super, then do any unpacking necessary for the
 subclass' attributes.
 */
- (void)unpackDictionary:(NSDictionary *)dictionary;

/**
 The default implementation compares the `updatedAt` property with the `updated_at` contained in the dictionary. If
 either is `nil`, it will unpack the dictionary.
 */
- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary;


///----------------
/// @name Utilities
///----------------

/**
 Returns `YES` if the `remoteID` property is not `nil`.
 */
- (BOOL)isRemote;

/**
 Parse a date in a dictionary from the server. A NSNumber containing the number of seconds since 1970 or a NSString
 containing an ISO8601 string are the only valid values for `dateStringOrDateNumber`.

 DEPRECATED. Please use the `ISO8601` library instead: https://github.com/soffes/ISO8601
 */
+ (NSDate *)parseDate:(id)dateStringOrDateNumber DEPRECATED_ATTRIBUTE;

@end

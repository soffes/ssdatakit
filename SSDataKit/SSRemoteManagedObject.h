//
//  SSRemoteManagedObject.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2013 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSManagedObject.h"

@interface SSRemoteManagedObject : SSManagedObject

@property (nonatomic, strong) NSNumber *remoteID;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. The object will be created if it is not found. If a context is not specified, the `mainContext`
 will be used.
 */
+ (id)objectWithRemoteID:(NSNumber *)remoteID;
+ (id)objectWithRemoteID:(NSNumber *)remoteID context:(NSManagedObjectContext *)context;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. `nil` is returned if the object is not found. If a context is not specified, the `mainContext`
 will be used.
 */
+ (id)existingObjectWithRemoteID:(NSNumber *)remoteID;
+ (id)existingObjectWithRemoteID:(NSNumber *)remoteID context:(NSManagedObjectContext *)context;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. The object will be created if it is not found. If a context is not specified, the `mainContext`
 will be used.

 The dictionary will be unpacked if `shouldUnpackDictionary:` returns `YES`.
 */
+ (id)objectWithDictionary:(NSDictionary *)dictionary;
+ (id)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;

/**
 Find an existing object with a given remote ID. The class' entity is used in the find. Therefore, this should only be
 called on a subclass. `nil` is returned if the object is not found. If a context is not specified, the `mainContext`
 will be used.

 The dictionary will be unpacked if `shouldUnpackDictionary:` returns `YES` and there is an object with the given ID.
 */
+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary;
+ (id)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context;

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

/**
 Returns `YES` if the `remoteID` property is greater than 0. `NO` is returned if the `remoteID` is `nil` or `0`.
 */
- (BOOL)isRemote;

/**
 Parse a date in a dictionary from the server. A NSNumber containing the number of seconds since 1970 or a NSString
 containing an ISO8601 string are the only valid values for `dateStringOrDateNumber`.
 */
+ (NSDate *)parseDate:(id)dateStringOrDateNumber;

@end

//
//  DKTRemoteManagedObject.m
//  Data Kit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "DKTRemoteManagedObject.h"

#import <SAMCategories/NSDate+SAMAdditions.h>

@implementation DKTRemoteManagedObject

@dynamic remoteID;
@dynamic createdAt;
@dynamic updatedAt;

#pragma mark - Configuration

+ (NSString *)remoteIDDictionaryKey {
	return @"id";
}


#pragma mark - Find or Create

+ (instancetype)objectWithRemoteID:(id)remoteID {
	return [self objectWithRemoteID:remoteID context:nil];
}


+ (instancetype)objectWithRemoteID:(id)remoteID context:(NSManagedObjectContext *)context {

	// If there isn't a suitable remoteID, we won't find the object. Return nil.
	if (!remoteID) {
		return nil;
	}

	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}

	// Look up the object
	DKTRemoteManagedObject *object = [self existingObjectWithRemoteID:remoteID context:context];

	// If the object doesn't exist, create it
	if (!object) {
		object = [[self alloc] initWithContext:context];
		object.remoteID = remoteID;
	}

	// Return the fetched or new object
	return object;
}


+ (instancetype)existingObjectWithRemoteID:(id)remoteID {
	return [self existingObjectWithRemoteID:remoteID context:nil];
}


+ (instancetype)existingObjectWithRemoteID:(id)remoteID context:(NSManagedObjectContext *)context {

	// If there isn't a suitable remoteID, we won't find the object. Return nil.
	if (!remoteID) {
		return nil;
	}

	// Default to the main context
	if (!context) {
		context = [self mainQueueContext];
	}

	// Create the fetch request for the ID
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self entityWithContext:context];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID = %@", remoteID];
	fetchRequest.fetchLimit = 1;

	// Execute the fetch request
	NSArray *results = [context executeFetchRequest:fetchRequest error:nil];

	// Return the object
	return [results lastObject];
}


+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary {
	return [self objectWithDictionary:dictionary context:nil];
}


+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {
	// Make sure we have a dictionary
	if (![dictionary isKindOfClass:[NSDictionary class]]) {
		return nil;
	}

	// Extract the remoteID from the dictionary
	id remoteID = [dictionary objectForKey:[self remoteIDDictionaryKey]];

	// Find object by remoteID
	DKTRemoteManagedObject *object = [[self class] objectWithRemoteID:remoteID context:context];

	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}

	// Return the new or updated object
	return object;
}


+ (instancetype)existingObjectWithDictionary:(NSDictionary *)dictionary {
	return [self existingObjectWithDictionary:dictionary context:nil];
}


+ (instancetype)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context {

	// Make sure we have a dictionary
	if (![dictionary isKindOfClass:[NSDictionary class]]) {
		return nil;
	}

	// Extract the remoteID from the dictionary
	id remoteID = [dictionary objectForKey:[self remoteIDDictionaryKey]];

	// Find object by remoteID
	DKTRemoteManagedObject *object = [[self class] existingObjectWithRemoteID:remoteID context:context];

	// Only unpack if necessary
	if ([object shouldUnpackDictionary:dictionary]) {
		[object unpackDictionary:dictionary];
	}

	// Return the new or updated object
	return object;
}


#pragma mark - Unpacking

- (void)unpackDictionary:(NSDictionary *)dictionary {
	if (!self.isRemote) {
		NSString *key = [[self class] remoteIDDictionaryKey];
		self.remoteID = dictionary[key];
	}

	if ([self respondsToSelector:@selector(setCreatedAt:)]) {
		self.createdAt = [NSDate sam_dateFromISO8601String:dictionary[@"created_at"]];
	}

	if ([self respondsToSelector:@selector(setUpdatedAt:)]) {
		self.updatedAt = [NSDate sam_dateFromISO8601String:dictionary[@"updated_at"]];
	}
}


- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary {
	if (![self respondsToSelector:@selector(updatedAt)] || !self.updatedAt) {
		return YES;
	}

	NSDate *newDate = [NSDate sam_dateFromISO8601String:dictionary[@"updated_at"]];
	if (newDate && [self.updatedAt compare:newDate] == NSOrderedAscending) {
		return YES;
	}

	return NO;
}


#pragma mark - Utilities

- (BOOL)isRemote {
	return self.remoteID != nil;
}


+ (NSArray *)defaultSortDescriptors {
	if ([self instancesRespondToSelector:@selector(createdAt)]) {
		return @[
			[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO],
			[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:NO]
		];
	}

	return @[[NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:NO]];
}

@end

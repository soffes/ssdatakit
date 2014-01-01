//
//  NSManagedObjectContext+SSDataKitAdditions.m
//  SSDataKit
//
//  Created by Sam Soffes on 1/25/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "NSManagedObjectContext+SSDataKitAdditions.h"

@implementation NSManagedObjectContext (SSDataKitAdditions)

- (NSManagedObjectContext *)newManagedObjectContextWithCurrentPersistentStoreCoordinator {
	NSManagedObjectContext *context = [[[self class] alloc] init];
	context.persistentStoreCoordinator = self.persistentStoreCoordinator;
	return context;
}

@end

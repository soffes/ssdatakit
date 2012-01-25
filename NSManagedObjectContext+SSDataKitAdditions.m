//
//  NSManagedObjectContext+SSDataKitAdditions.m
//  Disposamatic
//
//  Created by Sam Soffes on 1/25/12.
//  Copyright (c) 2012 Synthetic. All rights reserved.
//

#import "NSManagedObjectContext+SSDataKitAdditions.h"

@implementation NSManagedObjectContext (SSDataKitAdditions)

- (NSManagedObjectContext *)newManagedObjectContextWithCurrentPersistentStoreCoordinator {
	NSManagedObjectContext *context = [[[self class] alloc] init];
	context.persistentStoreCoordinator = self.persistentStoreCoordinator;
	return context;
}

@end

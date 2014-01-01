//
//  NSManagedObjectContext+SSDataKitAdditions.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/25/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (SSDataKitAdditions)

// Creates a new context of the same class and sets its persistent store coordinator to the current one
- (NSManagedObjectContext *)newManagedObjectContextWithCurrentPersistentStoreCoordinator;

@end

//
//  NSManagedObjectContext+SSDataKitAdditions.h
//  Disposamatic
//
//  Created by Sam Soffes on 1/25/12.
//  Copyright (c) 2012 Synthetic. All rights reserved.
//

@interface NSManagedObjectContext (SSDataKitAdditions)

// Creates a new context of the same class and sets its persistent store coordinator to the current one
- (NSManagedObjectContext *)newManagedObjectContextWithCurrentPersistentStoreCoordinator CF_RETURNS_RETAINED;

@end

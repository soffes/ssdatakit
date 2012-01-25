//
//  NSManagedObjectContext+SSDataKitAdditions.h
//  Disposamatic
//
//  Created by Sam Soffes on 1/25/12.
//  Copyright (c) 2012 Synthetic. All rights reserved.
//

@interface NSManagedObjectContext (SSDataKitAdditions)

- (NSManagedObjectContext *)newWithCurrentPersistentStoreCoordinator CF_RETURNS_RETAINED;

@end

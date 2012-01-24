//
//  SSManagedObjectContext.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/23/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObject.h"

@class SSManagedObjectContextObserver;

@interface SSManagedObjectContext : NSManagedObjectContext

// Observing
- (void)addObjectObserver:(SSManagedObjectContextObserver *)observer;
- (void)removeObjectObserver:(SSManagedObjectContextObserver *)observer;
- (void)removeAllObjectObservers;

// Unmagic
- (BOOL)saveWithoutMagic:(NSError **)error;

@end

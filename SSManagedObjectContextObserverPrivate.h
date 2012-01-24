//
//  SSManagedObjectContextObserverPrivate.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObjectContextObserver.h"

@class SSManagedObjectContext;

@interface SSManagedObjectContextObserver ()

- (void)_processContextAfterSave:(SSManagedObjectContext *)context insertedObject:(NSSet *)insertedObjects updatedObjects:(NSSet *)updatedObjects;

@end
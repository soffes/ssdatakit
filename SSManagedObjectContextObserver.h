//
//  SSManagedObjectContextObserver.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObject.h"

@class SSManagedObjectContext;

typedef void (^SSManagedObjectContextObserverObservationBlock)(NSSet *insertedObjectIDs, NSSet *updatedObjectIDs);

@interface SSManagedObjectContextObserver : NSObject

@property (nonatomic, retain) NSEntityDescription *entity;

@property (nonatomic, copy) SSManagedObjectContextObserverObservationBlock observationBlock;

@property (nonatomic, retain, readonly) SSManagedObjectContext *managedObjectContext;

- (id)initWithContext:(SSManagedObjectContext *)context;

@end

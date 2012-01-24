//
//  SSManagedObjectContextObserver.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObject.h"

typedef void (^SSManagedObjectContextObserverObservationBlock)(NSSet *insertedObjectIDs, NSSet *updatedObjectIDs);

@interface SSManagedObjectContextObserver : NSObject

@property (nonatomic, retain) NSEntityDescription *entity;
@property (nonatomic, copy) SSManagedObjectContextObserverObservationBlock observationBlock;

@end

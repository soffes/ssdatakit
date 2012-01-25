//
//  SSManagedObjectController.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

@class SSManagedObjectContext;

@interface SSManagedObjectController : NSObject

- (SSManagedObjectContext *)managedObjectContext;
- (NSEntityDescription *)entity;
- (void)setup;
- (void)processObjectID:(NSManagedObjectID *)objectID;

@end

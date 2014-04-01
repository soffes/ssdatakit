//
//  NSManagedObject+DKTAdditions.h
//  Data Kit
//
//  Created by Sam Soffes on 4/1/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DKTAdditions)

- (NSManagedObjectID *)dkt_permanentObjectID;
- (BOOL)dkt_save;
- (void)dkt_delete;

@end

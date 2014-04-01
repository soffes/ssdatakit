//
//  NSManagedObject+DKTAdditions.m
//  Data Kit
//
//  Created by Sam Soffes on 4/1/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "NSManagedObject+DKTAdditions.h"

@implementation NSManagedObject (DKTAdditions)

- (NSManagedObjectID *)dkt_permanentObjectID {
	if ([[self objectID] isTemporaryID]) {
		[[self managedObjectContext] obtainPermanentIDsForObjects:@[self] error:nil];
	}
	return [self objectID];
}


- (BOOL)dkt_save {
	return [self.managedObjectContext save:nil];
}


- (void)dkt_delete {
	[self.managedObjectContext deleteObject:self];
}

@end

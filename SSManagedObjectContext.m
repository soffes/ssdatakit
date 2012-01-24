//
//  SSManagedObjectContext.m
//  SSDataKit
//
//  Created by Sam Soffes on 1/23/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObjectContext.h"
#import "SSManagedObjectContextObserver.h"
#import "SSManagedObjectContextObserverPrivate.h"

@implementation SSManagedObjectContext {
	NSMutableSet *_observers;
}

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		_observers = [[NSMutableSet alloc] init];
	}
	return self;
}


- (void)dealloc {
	[self removeAllObjectObservers];
	[_observers release];
	[super dealloc];
}


#pragma mark - NSManagedObjectContext

- (BOOL)save:(NSError **)error {
	NSSet *insertedObjects = [[self insertedObjects] copy];
	NSSet *updatedObjects = [[self updatedObjects] copy];	
	
	BOOL sucess = [self saveWithoutMagic:error];
	
	for (SSManagedObjectContextObserver *observer in _observers) {
		[observer _processContextAfterSave:self insertedObject:insertedObjects updatedObjects:updatedObjects];
	}
	
	[insertedObjects release];
	[updatedObjects release];
	
	return sucess;
}


#pragma mark - Observers

- (void)addObjectObserver:(SSManagedObjectContextObserver *)observer {
	[_observers addObject:observer];
}


- (void)removeObjectObserver:(SSManagedObjectContextObserver *)observer {
	[_observers removeObject:observer];
}


- (void)removeAllObjectObservers {
	[_observers removeAllObjects];
}


#pragma mark - Unmagic

- (BOOL)saveWithoutMagic:(NSError **)error {
	return [super save:error];
}

@end

//
//  SSManagedObjectContextObserver.m
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObjectContextObserver.h"
#import "SSManagedObjectContext.h"
#import "SSManagedObjectContextPrivate.h"

@interface SSManagedObjectContextObserver ()
- (BOOL)_objectMatchesCriteria:(NSManagedObject *)object;
@end

@implementation SSManagedObjectContextObserver

@synthesize entity = _entity;
@synthesize observationBlock = _observationBlock;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - NSObject

- (id)init {
	return (self = [self initWithContext:[SSManagedObject mainContext]]);
}


- (void)dealloc {
	[_managedObjectContext _removeObserver:self];
	_managedObjectContext = nil;
	[_observationBlock release];
	[_entity release];
	[super dealloc];
}


#pragma mark - Initializing

- (id)initWithContext:(SSManagedObjectContext *)context {
	if ((self = [super init])) {
		_managedObjectContext = [context retain];
		[_managedObjectContext _addObserver:self];
	}
	return self;
}


#pragma mark - Private

- (void)_processContextAfterSave:(SSManagedObjectContext *)context insertedObject:(NSSet *)insertedObjects updatedObjects:(NSSet *)updatedObjects {
	if (!_observationBlock) {
		return;
	}
	
	// Inserted
	NSMutableSet *inserted = [[NSMutableSet alloc] init];
	for (NSManagedObject *object in insertedObjects) {
		if ([self _objectMatchesCriteria:object]) {
			[inserted addObject:object.objectID];
		}
	}
	
	// Updated
	NSMutableSet *updated = [[NSMutableSet alloc] init];	
	for (NSManagedObject *object in updatedObjects) {
		if ([self _objectMatchesCriteria:object]) {
			[updated addObject:object.objectID];
		}
	}
	
	// Notify the block if there is interesting stuff
	if (inserted.count > 0 || updated.count > 0) {
		_observationBlock(inserted, updated);
	}
	
	[inserted release];
	[updated release];
}


- (BOOL)_objectMatchesCriteria:(NSManagedObject *)object {
	// Check entity
	if (_entity && [object.entity isEqual:_entity] == NO) {
		return NO;
	}
	
	return YES;
}

@end

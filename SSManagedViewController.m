//
//  SSManagedViewController.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedViewController.h"
#import "SSManagedObject.h"

@implementation SSManagedViewController

@synthesize managedObject = _managedObject;
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - Accessors

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController) {
		_fetchedResultsController = [[[[self class] fetchedResultsControllerClass] alloc] initWithFetchRequest:self.fetchRequest
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:self.sectionNameKeyPath
																				   cacheName:self.cacheName];
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController performFetch:nil];
	}
	return _fetchedResultsController;
}


- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	_fetchedResultsController.delegate = nil;
	_fetchedResultsController = fetchedResultsController;
}


#pragma mark - NSObject

- (void)dealloc {
	self.fetchedResultsController = nil;
}


#pragma mark - Configuration

+ (Class)fetchedResultsControllerClass {
	return [NSFetchedResultsController class];
}


- (NSFetchRequest *)fetchRequest {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = [self.entityClass entityWithContext:self.managedObjectContext];
	fetchRequest.sortDescriptors = self.sortDescriptors;
	fetchRequest.predicate = self.predicate;
	return fetchRequest;
}


- (Class)entityClass {
	return [SSManagedObject class];
}


- (NSArray *)sortDescriptors {
	return [self.entityClass defaultSortDescriptors];
}


- (NSPredicate *)predicate {
	return nil;
}


- (NSManagedObjectContext *)managedObjectContext {
	return [self.entityClass mainContext];
}


- (NSString *)sectionNameKeyPath {
	return nil;
}


- (NSString *)cacheName {
	return nil;
}

@end

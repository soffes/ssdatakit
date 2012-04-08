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
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest]
																		managedObjectContext:[self managedObjectContext]
																		  sectionNameKeyPath:[self sectionNameKeyPath]
																				   cacheName:[self cacheName]];
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

- (NSFetchRequest *)fetchRequest {
	return nil;
}


- (NSArray *)sortDescriptors {
	return nil;
}


- (NSPredicate *)predicate {
	return nil;
}


- (NSManagedObjectContext *)managedObjectContext {
	return [SSManagedObject mainContext];
}


- (NSString *)sectionNameKeyPath {
	return nil;
}


- (NSString *)cacheName {
	return nil;
}

@end

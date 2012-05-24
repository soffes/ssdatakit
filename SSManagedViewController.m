//
//  SSManagedViewController.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedViewController.h"
#import "SSManagedObject.h"

@interface SSManagedViewController ()
- (void)_updateEmptyView:(BOOL)animated;
@end

@implementation SSManagedViewController

@synthesize managedObject = _managedObject;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize ignoreChange = _ignoreChange;
@synthesize emptyView = _emptyView;

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


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self _updateEmptyView:NO];
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


#pragma mark - Accessing Objects

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath {
	return fetchedIndexPath;
}


- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath {
	return viewIndexPath;
}


- (id)objectForViewIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:[self fetchedIndexPathForViewIndexPath:indexPath]];
}


#pragma mark - Private

- (void)_updateEmptyView:(BOOL)animated {
	if (!self.emptyView) {
		return;
	}

	NSInteger objectCount = self.fetchedResultsController.fetchedObjects.count;
	if (self.emptyView.superview && objectCount > 0) {
		if (animated) {
			[UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
				self.emptyView.alpha = 0.0f;
			} completion:^(BOOL finished) {
				[self.emptyView removeFromSuperview];
			}];
		} else {
			[self.emptyView removeFromSuperview];
		}
	} else if (!self.emptyView.superview && objectCount == 0) {
		if (animated) {
			self.emptyView.alpha = 0.0f;
			[self.view addSubview:self.emptyView];
			[UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
				self.emptyView.alpha = 1.0f;
			} completion:nil];
		} else {
			self.emptyView.frame = self.view.bounds;
			self.emptyView.alpha = 1.0f;
			[self.view addSubview:self.emptyView];
		}
	}
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self _updateEmptyView:YES];
}

@end

//
//  SSManagedViewController.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSManagedViewController.h"
#import "SSManagedObject.h"

@implementation SSManagedViewController

#pragma mark - Accessors

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController {
	if (!_fetchedResultsController && [SSManagedObject hasMainQueueContext]) {
		[self willCreateFetchedResultsController];
		_fetchedResultsController = [[[[self class] fetchedResultsControllerClass] alloc] initWithFetchRequest:self.fetchRequest
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:self.sectionNameKeyPath
																				   cacheName:self.cacheName];
		_fetchedResultsController.delegate = self;
		[_fetchedResultsController performFetch:nil];
		[self didCreateFetchedResultsController];
	}
	return _fetchedResultsController;
}


- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	_fetchedResultsController.delegate = nil;
	_fetchedResultsController = fetchedResultsController;
}


- (void)setLoading:(BOOL)loading {
	[self setLoading:loading animated:YES];
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.fetchedResultsController = nil;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Default animations on for subclasses that support this.
	self.useChangeAnimations = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextWillReset:) name:kSSManagedObjectWillResetNotificationName object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updatePlaceholderViews:NO];
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
    return [[self entityClass] mainQueueContext];
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


#pragma mark - Callbacks

- (void)willCreateFetchedResultsController {
	// Subclasses may override this method
}


- (void)didCreateFetchedResultsController {
	// Subclasses may override this method
}


#pragma mark - Placeholders

- (void)setLoading:(BOOL)loading animated:(BOOL)animated {
	_loading = loading;
	[self updatePlaceholderViews:animated];
}


- (BOOL)hasContent {
	return self.fetchedResultsController.fetchedObjects.count > 0;
}


- (CGRect)placeholderViewsFrame {
	return self.view.bounds;
}


- (void)updatePlaceholderViews:(BOOL)animated {
	// Disable animated changes for now since they are buggy
	animated = NO;

	// There is content to be displayed
	if ([self hasContent]) {
		// Hide the loading and content view
		[self hideLoadingView:animated];
		[self hideNoContentView:animated];
		return;
	}

	// There is no content to be displayed.
	if ([self isLoading]) {
		// Show the loading view and hide the no content view
		[self hideNoContentView:animated];
		[self showLoadingView:animated];
	} else {
		// Show the no content view and hide the loading view
		[self hideLoadingView:animated];
		[self showNoContentView:animated];
	}
}


- (void)showLoadingView:(BOOL)animated {
	if (!self.loadingView || self.loadingView.superview) {
		return;
	}

	self.loadingView.alpha = 0.0f;
	self.loadingView.frame = [self placeholderViewsFrame];
	[self.view addSubview:self.loadingView];

	void (^change)(void) = ^{
		self.loadingView.alpha = 1.0f;
	};


	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:nil];
	} else {
		change();
	}
}


- (void)hideLoadingView:(BOOL)animated {
	if (!self.loadingView || !self.loadingView.superview) {
		return;
	}

	void (^change)(void) = ^{
		self.loadingView.alpha = 0.0f;
	};

	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[self.loadingView removeFromSuperview];
	};

	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:completion];
	} else {
		change();
		completion(YES);
	}
}


- (void)showNoContentView:(BOOL)animated {
	if (!self.noContentView || self.noContentView.superview) {
		return;
	}

	self.noContentView.alpha = 0.0f;
	self.noContentView.frame = [self placeholderViewsFrame];
	[self.view addSubview:self.noContentView];

	void (^change)(void) = ^{
		self.noContentView.alpha = 1.0f;
	};


	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:nil];
	} else {
		change();
	}
}


- (void)hideNoContentView:(BOOL)animated {
	if (!self.noContentView || !self.noContentView.superview) {
		return;
	}

	void (^change)(void) = ^{
		self.noContentView.alpha = 0.0f;
	};

	void (^completion)(BOOL finished) = ^(BOOL finished) {
		[self.noContentView removeFromSuperview];
	};

	if (animated) {
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:change completion:completion];
	} else {
		change();
		completion(YES);
	}
}


#pragma mark - Private

- (void)managedObjectContextWillReset:(NSNotification *)notification {
	self.fetchedResultsController = nil;
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self updatePlaceholderViews:YES];
}

@end

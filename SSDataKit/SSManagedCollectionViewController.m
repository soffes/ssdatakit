//
//  SSManagedCollectionViewController.m
//  SSDataKit
//
//  Created by Robert Dougan on 12/19/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSManagedCollectionViewController.h"

@interface SSManagedCollectionViewController ()
@property (nonatomic) NSMutableArray *objectChanges;
@property (nonatomic) NSMutableArray *sectionChanges;
@end

@implementation SSManagedCollectionViewController

#pragma mark - Accessors

@synthesize collectionView = _collectionView;
@synthesize objectChanges = _objectChanges;
@synthesize sectionChanges = _sectionChanges;

- (UICollectionView *)collectionView {
	return _collectionView;
}


- (NSMutableArray *)objectChanges {
	if (!_objectChanges) {
		_objectChanges = [[NSMutableArray alloc] init];
	}
	return _objectChanges;
}


- (NSMutableArray *)sectionChanges {
	if (!_sectionChanges) {
		_sectionChanges = [[NSMutableArray alloc] init];
	}
	return _sectionChanges;
}


#pragma mark - NSObject

- (void)dealloc {
	self.collectionView.dataSource = nil;
	self.collectionView.delegate = nil;
}


#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

	// Add the collection view as a subview for increased flexibility
	self.collectionView.frame = self.view.bounds;
	[self.view addSubview:self.collectionView];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.collectionView flashScrollIndicators];
}


#pragma mark - SSManagedViewController

- (void)didCreateFetchedResultsController {
	[self.collectionView reloadData];
}


#pragma mark - Initializer

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout {
	if ((self = [super init])) {
		_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
		_collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_collectionView.dataSource = self;
		_collectionView.delegate = self;
	}
	return self;
}


#pragma mark - Working with Cells

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// Subclasses should override this method
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Subclasses should override this method
	return nil;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.objectChanges = [[NSMutableArray alloc] init];
	self.sectionChanges = [[NSMutableArray alloc] init];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:NSNotFound inSection:sectionIndex];
    indexPath = [self viewIndexPathForFetchedIndexPath:indexPath];
    sectionIndex = indexPath.section;

    NSMutableDictionary *change = [NSMutableDictionary new];

    switch(type) {
		case NSFetchedResultsChangeInsert: {
            change[@(type)] = @[@(sectionIndex)];
            break;
		}

		case NSFetchedResultsChangeDelete: {
            change[@(type)] = @[@(sectionIndex)];
            break;
		}

		default: {
			// Do nothing
		}
    }

    [self.sectionChanges addObject:change];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}

    indexPath = [self viewIndexPathForFetchedIndexPath:indexPath];
    newIndexPath = [self viewIndexPathForFetchedIndexPath:newIndexPath];

    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.objectChanges addObject:change];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[super controllerDidChangeContent:controller];

    if (![self useChangeAnimations]) {
        [self.collectionView reloadData];
        return;
    }

    // Copy state so it can't be mutated out from under us
    NSArray *sectionChanges = [self.sectionChanges copy];
    NSArray *objectChanges = [self.objectChanges copy];
	self.sectionChanges = nil;
	self.objectChanges = nil;

    // Perform updates
    [self.collectionView performBatchUpdates:^{

        // Section changes
        for (NSDictionary *change in sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type) {
					case NSFetchedResultsChangeInsert: {
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
					}

					case NSFetchedResultsChangeDelete: {
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
					}

					case NSFetchedResultsChangeUpdate: {
                        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
					}

					default: {
						// Do nothing
					}
                }
            }];
        }

        // Object changes
        for (NSDictionary *change in objectChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }

    } completion:nil];
}

@end

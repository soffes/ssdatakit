//
//  SSManagedCollectionViewController.m
//  SSDataKit
//
//  Created by Robert Dougan on 12/19/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSManagedCollectionViewController.h"

@implementation SSManagedCollectionViewController {
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

#pragma mark - NSObject

- (void)dealloc {
	_collectionView.dataSource = nil;
	_collectionView.delegate = nil;
}


#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

	// Add the collection view as a subview for increased flexibility
	_collectionView.frame = self.view.bounds;
	[self.view addSubview:_collectionView];
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
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
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
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @[@(sectionIndex)];
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @[@(sectionIndex)];
            break;
    }

    [_sectionChanges addObject:change];
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
    [_objectChanges addObject:change];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (![self useChangeAnimations]) {
        [self.collectionView reloadData];
        return;
    }
    
    // Copy state so it can't be mutated out from under us
    NSArray *sectionChanges = [_sectionChanges copy];
    NSArray *objectChanges = [_objectChanges copy];
    _sectionChanges = nil;
    _objectChanges = nil;
    
    // Perform updates
    [self.collectionView performBatchUpdates:^{
        
        // Section changes
        for (NSDictionary *change in sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
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

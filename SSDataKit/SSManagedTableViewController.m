//
//  SSManagedTableViewController.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSManagedTableViewController.h"

@implementation SSManagedTableViewController

#pragma mark - NSObject

- (instancetype)init {
	return (self = [self initWithStyle:UITableViewStylePlain]);
}


- (void)dealloc {
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
}


#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

	// Add the table view as a subview for increased flexibility
	_tableView.frame = self.view.bounds;
	[self.view addSubview:_tableView];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (_clearsSelectionOnViewWillAppear) {
		[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
	}
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[self.tableView setEditing:editing animated:animated];
}


#pragma mark - SSManagedViewController

- (void)didCreateFetchedResultsController {
	[self.tableView reloadData];
}


#pragma mark - Initializer

- (instancetype)initWithStyle:(UITableViewStyle)style {
	if ((self = [super init])) {
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_clearsSelectionOnViewWillAppear = YES;
	}
	return self;
}


#pragma mark - Working with Cells

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// Subclasses should override this method
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Subclasses should override this method. This is a placeholder implementation:

	static NSString *const reuseIdentifier = @"SSManagedTableViewControllerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}

	[self configureCell:cell atIndexPath:indexPath];

	return cell;
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:sectionIndex];
    indexPath = [self viewIndexPathForFetchedIndexPath:indexPath];
    sectionIndex = indexPath.section;

    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
		}

        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
		}

		default: {
			// Do nothing
		}
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	if (self.ignoreChange || ![self useChangeAnimations]) {
		return;
	}

    UITableView *tableView = self.tableView;
	indexPath = [self viewIndexPathForFetchedIndexPath:indexPath];
	newIndexPath = [self viewIndexPathForFetchedIndexPath:newIndexPath];

    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}

        case NSFetchedResultsChangeDelete: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}

        case NSFetchedResultsChangeUpdate: {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
		}

        case NSFetchedResultsChangeMove: {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[super controllerDidChangeContent:controller];
	if (self.ignoreChange) {
		return;
	}

	if ([self useChangeAnimations]) {
		[self.tableView endUpdates];
	} else {
		[self.tableView reloadData];
	}
}

@end

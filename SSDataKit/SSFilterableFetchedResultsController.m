//
//  SSFilterableFetchedResultsController.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSFilterableFetchedResultsController.h"
#import "SSFilteredResultsSection.h"

@interface SSFilterableFetchedResultsController () <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableDictionary *filters;
@property (nonatomic) SSFilteredResultsFilter *currentFilter;
@end


@implementation SSFilterableFetchedResultsController

- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest
	   managedObjectContext:(NSManagedObjectContext *)context
		 sectionNameKeyPath:(NSString *)sectionNameKeyPath
				  cacheName:(NSString *)name {
    self = [super init];
    if (!self) {
        return nil;
    }

	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:sectionNameKeyPath cacheName:name];
	fetchedResultsController.delegate = self;
	self.fetchedResultsController = fetchedResultsController;

	self.filters = [NSMutableDictionary dictionary];

	return self;
}


- (void)dealloc {
	self.delegate = nil;
	self.currentFilter = nil;
	self.fetchedResultsController.delegate = nil;
}


- (void)addFilterPredicate:(SSFilterableFetchedResultsFilterPredicate)predicate forKey:(NSString *)key {
	SSFilteredResultsFilter *f = [[SSFilteredResultsFilter alloc] init];

	f.predicate = predicate;
	f.sections = [NSMutableArray array];

	[self.filters setObject:f forKey:key];
}


- (void)setActiveFilterByKey:(NSString *)key {
	SSFilteredResultsFilter *currentFilter = self.currentFilter;
	SSFilteredResultsFilter *newFilter = nil;

	if (key) {
		newFilter = [self.filters objectForKey:key];
	}

	if (![newFilter isEqual:currentFilter]) {
		self.currentFilter = newFilter;
		[self _updateObjectsForCurrentFilter:currentFilter newFilter:newFilter];
	}
}


- (void)removeCurrentFilter {
	[self addFilterPredicate:^BOOL(id obj) {
		return YES;
	} forKey:@"__all"];
	[self setActiveFilterByKey:@"__all"];
	self.currentFilter = nil;
	[self.filters removeAllObjects];
}


- (void)rebuildCurrentFilter
{
	[self.currentFilter.sections removeAllObjects];
	
	for(int i = 0; i < self.fetchedResultsController.sections.count; i++) {
		id<NSFetchedResultsSectionInfo> section = (id<NSFetchedResultsSectionInfo>)[self.fetchedResultsController.sections objectAtIndex:i];
		
		SSFilteredResultsSection *newFilteredSection = [[SSFilteredResultsSection alloc] init];
		newFilteredSection.internalName = section.name;
		newFilteredSection.internalIndexTitle = section.indexTitle;
		
		for(int j = 0; j < section.objects.count; j++) {
			NSObject *o = [section.objects objectAtIndex:j];
			
			if (self.currentFilter.predicate(o)) {
				[newFilteredSection addObject:o];
			}
		}
		
		[self.currentFilter.sections addObject:newFilteredSection];
	}
}


- (void)_updateObjectsForCurrentFilter:(SSFilteredResultsFilter *)currentFilter newFilter:(SSFilteredResultsFilter *)newFilter {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
		[self.delegate controllerWillChangeContent:self.fetchedResultsController];
	}

	if (!newFilter && currentFilter) {
		//Update Back To "Show All / Do not filter at all"

		for(int i = 0; i < self.fetchedResultsController.sections.count; i++) {
			id<NSFetchedResultsSectionInfo> section = (id<NSFetchedResultsSectionInfo>)[self.fetchedResultsController.sections objectAtIndex:i];

			for(int j = 0; j < section.objects.count; j++) {
				NSObject *o = [section.objects objectAtIndex:j];

				if (!currentFilter.predicate(o)) {
					if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
						[self.delegate controller:self.fetchedResultsController
								  didChangeObject:o
									  atIndexPath:nil
									forChangeType:NSFetchedResultsChangeInsert
									 newIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
					}
				}
			}
		}
	} else if (newFilter && !currentFilter) {
		//Going From showing "All" to showing a filter

		[newFilter.sections removeAllObjects];

		for(int i = 0; i < self.fetchedResultsController.sections.count; i++) {
			id<NSFetchedResultsSectionInfo> section = (id<NSFetchedResultsSectionInfo>)[self.fetchedResultsController.sections objectAtIndex:i];

			SSFilteredResultsSection *filteredSection = [[SSFilteredResultsSection alloc] init];
			filteredSection.internalName = section.name;
			filteredSection.internalIndexTitle = section.indexTitle;

			for(int j = 0; j < section.objects.count; j++) {
				NSObject *o = [section.objects objectAtIndex:j];

				if (!newFilter.predicate(o)) {
					if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
						[self.delegate controller:self.fetchedResultsController
								  didChangeObject:o
									  atIndexPath:[NSIndexPath indexPathForRow:j inSection:i]
									forChangeType:NSFetchedResultsChangeDelete
									 newIndexPath:nil];
					}
				} else {
					[filteredSection addObject:o];
				}
			}

			[newFilter.sections addObject:filteredSection];
		}
	} else if (newFilter && currentFilter) {
		//Going from one filter to another filter

		for(int i = 0; i < currentFilter.sections.count; i++) {
			SSFilteredResultsSection *section = (SSFilteredResultsSection *)[currentFilter.sections objectAtIndex:i];

			// Delete rows that do not pass the new filter
			for(int j = 0; j < section.objects.count; j++) {
				NSObject *o = [section.objects objectAtIndex:j];

				if (!newFilter.predicate(o)) {
					if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
						[self.delegate controller:self.fetchedResultsController
								  didChangeObject:o
									  atIndexPath:[NSIndexPath indexPathForRow:j inSection:i]
									forChangeType:NSFetchedResultsChangeDelete
									 newIndexPath:nil];
					}
				}
			}
		}

		[newFilter.sections removeAllObjects];

		for(int i = 0; i < self.fetchedResultsController.sections.count; i++) {
			id<NSFetchedResultsSectionInfo> section = (id<NSFetchedResultsSectionInfo>)[self.fetchedResultsController.sections objectAtIndex:i];

			SSFilteredResultsSection *currentFilteredSection = [currentFilter.sections objectAtIndex:i];
			SSFilteredResultsSection *filteredSection = [[SSFilteredResultsSection alloc] init];
			filteredSection.internalName = section.name;
			filteredSection.internalIndexTitle = section.indexTitle;

			// add all passable objects in section to the new filter
			for(int j = 0; j < section.objects.count; j++) {
				NSObject *o = [section.objects objectAtIndex:j];

				if (newFilter.predicate(o)) {
					[filteredSection addObject:o];
				}
			}

			[newFilter.sections addObject:filteredSection];

			for (int j = 0; j < filteredSection.objects.count; j++) {
				NSObject *o = [filteredSection.objects objectAtIndex:j];
				BOOL foundInCurrentFilter = NO;

				for (int k = 0; k < currentFilteredSection.objects.count; k++) {
					if (o == [currentFilteredSection.objects objectAtIndex:k]) {
						foundInCurrentFilter = YES;
						if (j != k) {
							// Move rows that still pass the filter but need to be moved.
							if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
								[self.delegate controller:self.fetchedResultsController
										  didChangeObject:o
											  atIndexPath:[NSIndexPath indexPathForRow:k inSection:i]
											forChangeType:NSFetchedResultsChangeMove
											 newIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
							}
						}
					}
				}
				if (!foundInCurrentFilter) {
					// Insert rows that did not pass the current filter but do pass the new filter
					if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
						[self.delegate controller:self.fetchedResultsController
								  didChangeObject:o
									  atIndexPath:nil
									forChangeType:NSFetchedResultsChangeInsert
									 newIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
					}
				}
			}
		}
	}

	if ([(NSObject *)self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
		[self.delegate controllerDidChangeContent:self.fetchedResultsController];
	}
}


#pragma mark NSFetchedResultsController Pass Throughs

- (BOOL) performFetch:(NSError **)error {
	return [self.fetchedResultsController performFetch:error];
}


- (NSArray *)fetchedObjects {
	NSMutableArray *arr = [NSMutableArray array];

	if (self.currentFilter == nil) {
		for(int i = 0; i < self.fetchedResultsController.sections.count; i++) {
			id<NSFetchedResultsSectionInfo> section = (id<NSFetchedResultsSectionInfo>)[self.fetchedResultsController.sections objectAtIndex:i];

			[arr addObjectsFromArray:section.objects];
		}
	} else {
		for(int i = 0; i < self.currentFilter.sections.count; i++) {
			SSFilteredResultsSection *section = (SSFilteredResultsSection *)[self.currentFilter.sections objectAtIndex:i];

			[arr addObjectsFromArray:section.objects];
		}
	}

	return arr;
}


- (NSArray *)unfilteredFetchedObjects {
	return self.fetchedResultsController.fetchedObjects;
}


- (NSArray *)sections {
	if (self.currentFilter == nil) {
		return [self.fetchedResultsController sections];
	} else {
		return [self.currentFilter sections];
	}
}


- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath) {
		return nil;
	}

	if (!self.currentFilter) {
		return [self.fetchedResultsController objectAtIndexPath:indexPath];
	} else {
		return [self.currentFilter objectAtIndexPath:indexPath];
	}
}


- (NSIndexPath *)indexPathForObject:(id)object {
	if (!self.currentFilter) {
		return [self.fetchedResultsController indexPathForObject:object];
	} else {
		return [self.currentFilter indexPathForObject:object];
	}
}


- (NSManagedObjectContext *)managedObjectContext {
	return self.fetchedResultsController.managedObjectContext;
}


- (NSString *)cacheName {
	return self.fetchedResultsController.cacheName;
}


- (NSString *)sectionNameKeyPath {
	return self.fetchedResultsController.sectionNameKeyPath;
}


- (NSFetchRequest *)fetchRequest {
	return self.fetchedResultsController.fetchRequest;
}


+ (void)deleteCacheWithName:(NSString *)name {
	[NSFetchedResultsController deleteCacheWithName:name];
}


- (NSArray *)sectionIndexTitles {
	// TODO: This may not be reliable when filtering is on
	return self.fetchedResultsController.sectionIndexTitles;
}


- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName {
	// TODO: This may not be reliable when filtering is on
	return [self.fetchedResultsController sectionIndexTitleForSectionName:sectionName];
}


- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex {
	// TODO: This may not be reliable when filtering is on
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:sectionIndex];
}


#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(controllerWillChangeContent:)]) {
		[self.delegate controllerWillChangeContent:controller];
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
		if (self.currentFilter) {
			if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeUpdate) {
				[self rebuildCurrentFilter];
				indexPath = [self indexPathForObject:anObject];
				if (indexPath) {
					[self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
				}
			} else if (type == NSFetchedResultsChangeMove) {
				NSIndexPath *previousIndexInFilter = [self.currentFilter indexPathForObject:anObject];
				[self rebuildCurrentFilter];
				NSIndexPath *indexInFilter = [self.currentFilter indexPathForObject:anObject];
				
				if (previousIndexInFilter && indexInFilter) {
					[self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:NSFetchedResultsChangeMove newIndexPath:newIndexPath];
				} else if (!previousIndexInFilter && indexInFilter) {
					newIndexPath = [self.currentFilter indexPathForObject:anObject];
					[self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:NSFetchedResultsChangeInsert newIndexPath:newIndexPath];
				} else if (previousIndexInFilter && !indexInFilter) {
					indexPath = previousIndexInFilter;
					[self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:NSFetchedResultsChangeDelete newIndexPath:newIndexPath];
				}
			} else if (type == NSFetchedResultsChangeDelete) {
				indexPath = [self.currentFilter indexPathForObject:anObject];
				if (indexPath) {
					[self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:NSFetchedResultsChangeDelete newIndexPath:newIndexPath];
				}
				[self rebuildCurrentFilter];
			}
		} else {
			[self.delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
		}
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)]) {
		[self.delegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(controllerDidChangeContent:)]) {
		[self.delegate controllerDidChangeContent:controller];
	}
}

@end

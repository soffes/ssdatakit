//
//  SSFilterableFetchedResultsController.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//
//  NOTE: This class is a work in progress and may not be production ready.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSFilteredResultsFilter.h"

@protocol SSFilterableFetchedResultsControllerDelegate;

// Even though this is a subclass of NSObject, it is a drop-in replacement for NSFetchedResultsController. It implements
// all of the methods and properties NSFetchedResultsController implements.
@interface SSFilterableFetchedResultsController : NSObject

@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;
@property (nonatomic, readonly) NSString *cacheName;
@property (nonatomic, assign) id<SSFilterableFetchedResultsControllerDelegate> delegate;
@property (nonatomic, readonly) NSArray *fetchedObjects;
@property (nonatomic, readonly) NSArray *sections;

// NSFetchedResultsController
- (id)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext: (NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name;
- (BOOL)performFetch:(NSError **)error;
+ (void)deleteCacheWithName:(NSString *)name;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

// Filtering
- (void)addFilterPredicate:(SSFilterableFetchedResultsFilterPredicate)predicate forKey:(NSString *)key;
- (void)setActiveFilterByKey:(NSString *)key;
- (void)removeCurrentFilter;

// TODO: This may not be reliable when filtering is on
@property (nonatomic, readonly) NSArray *sectionIndexTitles;
- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex;

@end


@protocol SSFilterableFetchedResultsControllerDelegate <NSObject>

@optional

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName;

@end

//
//  SSFilterableFetchedResultsController.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SSFilteredResultsFilter.h"

// Even though this is a subclass of NSObject, it is a drop-in replacement for NSFetchedResultsController. It implements
// all of the methods and properties NSFetchedResultsController implements.
@interface SSFilterableFetchedResultsController : NSObject

@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;
@property (nonatomic, readonly) NSString *cacheName;
@property (nonatomic, weak) id<NSFetchedResultsControllerDelegate> delegate;
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

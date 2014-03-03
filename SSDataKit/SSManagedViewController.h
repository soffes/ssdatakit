//
//  SSManagedViewController.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class SSManagedObject;

@interface SSManagedViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic) SSManagedObject *managedObject;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL ignoreChange;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic) UIView *noContentView;
@property (nonatomic) UIView *loadingView;
@property (nonatomic) BOOL useChangeAnimations;

+ (Class)fetchedResultsControllerClass;
- (NSFetchRequest *)fetchRequest;
- (Class)entityClass;
- (NSArray *)sortDescriptors;
- (NSPredicate *)predicate;
- (NSManagedObjectContext *)managedObjectContext;
- (NSString *)sectionNameKeyPath;
- (NSString *)cacheName;

- (void)willCreateFetchedResultsController;
- (void)didCreateFetchedResultsController;

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath;
- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath;
- (id)objectForViewIndexPath:(NSIndexPath *)indexPath;

- (void)setLoading:(BOOL)loading animated:(BOOL)animated;
- (BOOL)hasContent;
- (void)updatePlaceholderViews:(BOOL)animated;
- (CGRect)placeholderViewsFrame;
- (void)showLoadingView:(BOOL)animated;
- (void)hideLoadingView:(BOOL)animated;
- (void)showNoContentView:(BOOL)animated;
- (void)hideNoContentView:(BOOL)animated;

@end

//
//  SSManagedViewController.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@class SSManagedObject;

@interface SSManagedViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) SSManagedObject *managedObject;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (NSFetchRequest *)fetchRequest;
- (NSArray *)sortDescriptors;
- (NSPredicate *)predicate;
- (NSManagedObjectContext *)managedObjectContext;
- (NSString *)sectionNameKeyPath;
- (NSString *)cacheName;

@end

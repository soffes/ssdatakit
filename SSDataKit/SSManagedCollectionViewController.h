//
//  SSManagedCollectionViewController.h
//  SSDataKit
//
//  Created by Robert Dougan on 12/19/12.
//  Copyright (c) 2012 Robert Dougan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "SSManagedViewController.h"

@interface SSManagedCollectionViewController : SSManagedViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

- (id)initWithLayout:(UICollectionViewLayout *)layout;
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

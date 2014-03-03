//
//  SSManagedCollectionViewController.h
//  SSDataKit
//
//  Created by Robert Dougan on 12/19/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSManagedViewController.h"

@interface SSManagedCollectionViewController : SSManagedViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, readonly) UICollectionView *collectionView;

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout;
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

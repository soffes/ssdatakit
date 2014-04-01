//
//  DKTManagedTableViewController.h
//  Data Kit
//
//  Created by Sam Soffes on 4/7/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "DKTManagedViewController.h"

@interface DKTManagedTableViewController : DKTManagedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;

- (instancetype)initWithStyle:(UITableViewStyle)style;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

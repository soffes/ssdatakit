//
//  DataKit.h
//  Data Kit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

// Core
#import <DataKit/DKTManagedObject.h>
#import <DataKit/DKTRemoteManagedObject.h>

// Categories
#import <DataKit/NSManagedObjectContext+DKTAdditions.h>
#import <DataKit/NSEntityDescription+DKTAdditions.h>
#import <DataKit/NSPropertyDescription+DKTAdditions.h>
#import <DataKit/NSManagedObject+DKTAdditions.h>

// View Controllers
#if TARGET_OS_IPHONE
	#import <DataKit/DKTManagedViewController.h>
	#import <DataKit/DKTManagedTableViewController.h>

	#ifdef __IPHONE_6_0
		#import <DataKit/DKTManagedCollectionViewController.h>
	#endif
#endif

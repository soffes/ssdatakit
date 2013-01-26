//
//  SSDataKit.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SSManagedObject.h"
#import "SSRemoteManagedObject.h"

#import "NSManagedObjectContext+SSDataKitAdditions.h"

#if TARGET_OS_IPHONE
    #import "SSManagedViewController.h"
    #import "SSManagedTableViewController.h"

    #ifdef __IPHONE_6_0
        #import "SSManagedCollectionViewController.h"
    #endif

	//  NOTE: This class is a work in progress and may not be production ready.
	#import "SSFilterableFetchedResultsController.h"
#endif

//
//  SSManagedObjectContextPrivate.h
//  SSDataKit
//
//  Created by Sam Soffes on 1/24/12.
//  Copyright (c) 2012 Sam Soffes. All rights reserved.
//

#import "SSManagedObjectContext.h"

@interface SSManagedObjectContext ()

- (void)_addObserver:(SSManagedObjectContextObserver *)observer;
- (void)_removeObserver:(SSManagedObjectContextObserver *)observer;

@end

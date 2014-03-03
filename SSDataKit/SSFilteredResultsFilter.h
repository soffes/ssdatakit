//
//  SSFilteredResultsFilter.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^SSFilterableFetchedResultsFilterPredicate)(id obj);

@interface SSFilteredResultsFilter : NSObject

@property (nonatomic, copy) SSFilterableFetchedResultsFilterPredicate predicate;
@property (nonatomic) NSMutableArray *sections;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

@end

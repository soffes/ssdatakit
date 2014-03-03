//
//  SSFilteredResultsSection.h
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SSFilteredResultsSection : NSObject <NSFetchedResultsSectionInfo>

@property (nonatomic) NSString *internalName;
@property (nonatomic) NSString *internalIndexTitle;

- (void)addObject:(NSObject *)object;

@end

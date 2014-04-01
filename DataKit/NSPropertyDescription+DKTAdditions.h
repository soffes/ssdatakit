//
//  NSPropertyDescription+DKTAdditions.h
//  Data Kit
//
//  Created by Sam Soffes on 3/31/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPropertyDescription (DKTAdditions)

- (id)dkt_minimumValue;
- (id)dkt_maximumValue;

@end

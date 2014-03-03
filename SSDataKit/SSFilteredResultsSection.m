//
//  SSFilteredResultsSection.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSFilteredResultsSection.h"

@implementation SSFilteredResultsSection {
	NSMutableArray *_objects;
}

- (id)init {
    if ((self = [super init])) {
		_objects = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)addObject:(NSObject *)o {
	[_objects addObject:o];
}


- (NSString *) name {
	return _internalName;
}


- (NSString *) indexTitle {
	return _internalIndexTitle;
}


- (NSUInteger) numberOfObjects {
	return _objects.count;
}


- (NSArray *)objects {
	return _objects;
}

@end

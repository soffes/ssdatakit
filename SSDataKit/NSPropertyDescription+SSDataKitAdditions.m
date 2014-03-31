//
//  NSPropertyDescription+SSDataKitAdditions.m
//  SSDataKit
//
//  Created by Sam Soffes on 3/31/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "NSPropertyDescription+SSDataKitAdditions.h"

@implementation NSPropertyDescription (SSDataKitAdditions)

- (id)ss_minimumValue {
	for (NSComparisonPredicate *predicate in [self validationPredicates]) {
		if (predicate.predicateOperatorType == NSGreaterThanOrEqualToPredicateOperatorType) {
			return [[predicate rightExpression] constantValue];
		}
	}
	return nil;
}


- (id)ss_maximumValue {
	for (NSComparisonPredicate *predicate in [self validationPredicates]) {
		if (predicate.predicateOperatorType == NSLessThanOrEqualToPredicateOperatorType) {
			return [[predicate rightExpression] constantValue];
		}
	}
	return nil;
}

@end

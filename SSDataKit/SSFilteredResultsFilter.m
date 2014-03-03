//
//  SSFilteredResultsFilter.m
//  SSDataKit
//
//  Created by Sam Soffes on 4/30/12.
//  Copyright (c) 2012-2014 Sam Soffes. All rights reserved.
//

#import "SSFilteredResultsFilter.h"
#import "SSFilteredResultsSection.h"
#import <UIKit/UIKit.h>

@implementation SSFilteredResultsFilter

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	SSFilteredResultsSection *section = [self.sections objectAtIndex:indexPath.section];
	return [section.objects objectAtIndex:indexPath.row];
}


- (NSIndexPath *)indexPathForObject:(id)object {
	NSInteger sectionIndex = 0;
	for (SSFilteredResultsSection *section in self.sections) {
		NSInteger rowIndex = 0;
		for (id obj in section.objects) {
			if ([obj isEqual:object]) {
				return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
			}
			rowIndex++;
		}
		sectionIndex++;
	}
	return nil;
}

@end


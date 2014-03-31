//
//  NSEntityDescription+SSDataKitAdditions.m
//  SSDataKit
//
//  Created by Sam Soffes on 3/31/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "NSEntityDescription+SSDataKitAdditions.h"

@implementation NSEntityDescription (SSDataKitAdditions)

- (NSAttributeDescription *)ss_attributeForName:(NSString *)name {
	return [self attributesByName][name];
}

@end

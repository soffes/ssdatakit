//
//  NSEntityDescription+DKTAdditions.m
//  Data Kit
//
//  Created by Sam Soffes on 3/31/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import "NSEntityDescription+DKTAdditions.h"

@implementation NSEntityDescription (DKTAdditions)

- (NSAttributeDescription *)dkt_attributeForName:(NSString *)name {
	return [self attributesByName][name];
}

@end

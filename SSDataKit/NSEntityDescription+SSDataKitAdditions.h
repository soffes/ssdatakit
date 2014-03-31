//
//  NSEntityDescription+SSDataKitAdditions.h
//  SSDataKit
//
//  Created by Sam Soffes on 3/31/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (SSDataKitAdditions)

- (NSAttributeDescription *)ss_attributeForName:(NSString *)name;

@end

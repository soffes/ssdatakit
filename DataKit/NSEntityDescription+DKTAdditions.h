//
//  NSEntityDescription+DKTAdditions.h
//  Data Kit
//
//  Created by Sam Soffes on 3/31/14.
//  Copyright (c) 2014 Sam Soffes. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (DKTAdditions)

- (NSAttributeDescription *)dkt_attributeForName:(NSString *)name;

@end

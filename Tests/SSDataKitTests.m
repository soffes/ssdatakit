//
//  SSDataKitTests.m
//  SSDataKitTests
//
//  Created by Sam Soffes on 6/27/13.
//  Copyright (c) 2013 Sam Soffes. All rights reserved.
//

#import "SSDataKitTests.h"

@implementation SSDataKitTests

- (void)testISO8601Parsing {
	NSString *iso8601 = @"2013-06-27T17:45:06Z";
	NSDate *date = [SSRemoteManagedObject parseDate:iso8601];
	STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1372355106], date, nil);
	
	iso8601 = @"2013-06-27T15:39:32.508Z";
	date = [SSRemoteManagedObject parseDate:iso8601];
	STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1372347572], date, nil);
}


- (void)testTimestampParsing {
	NSDate *date = [SSRemoteManagedObject parseDate:@1372355106];
	STAssertEqualObjects([NSDate dateWithTimeIntervalSince1970:1372355106], date, nil);
}

@end

//
//  newsmthTests.m
//  newsmthTests
//
//  Created by Maxwin on 13-5-24.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "newsmthTests.h"

@implementation newsmthTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    XLog_d(@"sss");
    NSString *content = @":A\n:b\nc\nd\n:e";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(^:|\\n:)[^\\n]*" options:NSRegularExpressionCaseInsensitive error:&error];
    int start = 0;
    while (true) {
        NSRange quoteRange = [regex rangeOfFirstMatchInString:content options:0 range:NSMakeRange(start, content.length - start)];
        if (quoteRange.location == NSNotFound) {
            break;
        }
        start = quoteRange.location + quoteRange.length;
        XLog_d(@"%@", NSStringFromRange(quoteRange));
    }

}

@end

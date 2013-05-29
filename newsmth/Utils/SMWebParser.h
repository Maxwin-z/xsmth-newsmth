//
//  SMWebParser.h
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMWebParser;

@protocol SMWebParserDelegate <NSObject>
@optional
- (void)webParser:(SMWebParser *)webParser result:(NSDictionary *)json;
@end

@interface SMWebParser : NSObject
@property (weak, nonatomic) id<SMWebParserDelegate> delegate;

- (void)parseHtml:(NSString *)html withJSFile:(NSString *)jsFile;
@end

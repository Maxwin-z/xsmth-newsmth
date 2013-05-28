//
//  SMWebParser.h
//  newsmth
//
//  Created by Maxwin on 13-5-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMWebParser : NSObject
@property (strong, nonatomic) UIWebView *webView;
- (void)parseHtml:(NSString *)html withJS:(NSString *)js;
@end

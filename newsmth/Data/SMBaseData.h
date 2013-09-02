//
//  SMBaseData.h
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMBaseData : NSObject

+ (SMBaseData *)dataWithJSON:(id)json;
+ (SMBaseData *)dataWithJSON:(id)json type:(NSString *)className;

- (id)initWithJSON:(id)json;
- (void)decode:(id)json;
- (id)encode;
@end

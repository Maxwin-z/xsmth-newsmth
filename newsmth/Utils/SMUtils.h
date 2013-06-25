//
//  SMUtils.h
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMUtils : NSObject
+ (NSString *)formatDate:(NSDate *)date;
+ (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label;
@end

//
//  SMConfig.m
//  newsmth
//
//  Created by Maxwin on 13-10-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMConfig.h"

@implementation SMConfig

+ (BOOL)configForKey:(NSString *)key defaults:(BOOL)defaults
{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj == nil ? defaults : [obj boolValue];
}

+ (BOOL)enableBackgroundFetch
{
    return [SMUtils systemVersion] >= 7 && [SMConfig configForKey:USERDEFAULTS_CONFIG_BACKGROUND_FETCH defaults:YES];
}



@end

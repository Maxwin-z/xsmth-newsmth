//
//  SMAdViewController.h
//  newsmth
//
//  Created by Maxwin on 14-2-9.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMViewController.h"

@interface SMAdViewController : SMViewController
+ (BOOL)hasAd;
+ (void)downloadAd:(NSString *)adid;
@end

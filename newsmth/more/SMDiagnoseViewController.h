//
//  SMDiagnoseViewController.h
//  newsmth
//
//  Created by Maxwin on 14-3-14.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMViewController.h"

@interface SMDiagnoseViewController : SMViewController
+ (void)diagnose:(NSString *)url rootViewController:(UIViewController *)vc;
@property (strong, nonatomic) NSString *url;
@end

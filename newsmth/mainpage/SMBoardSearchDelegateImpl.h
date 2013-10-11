//
//  SMBoardSearchDelegateImpl.h
//  newsmth
//
//  Created by Maxwin on 13-10-11.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMMainpageViewController.h"

@interface SMBoardSearchDelegateImpl : NSObject<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property (weak, nonatomic) SMMainpageViewController *mainpage;
@end

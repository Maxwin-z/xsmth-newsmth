//
//  SMPostWebLoaderOperation.h
//  newsmth
//
//  Created by Maxwin on 14-3-28.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMWebLoaderOperation.h"

@interface SMPostWebLoaderOperation : SMWebLoaderOperation
- (void)loadPost:(SMPost *)post fromMobile:(BOOL)m;
@end

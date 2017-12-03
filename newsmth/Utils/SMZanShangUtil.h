//
//  SMZanShangUtil.h
//  newsmth
//
//  Created by Maxwin on 03/12/2017.
//  Copyright © 2017 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMZanShangUtil : NSObject
+ (instancetype)sharedInstance;
- (void)addOpenCount;
- (void)addViewCount;
@end

//
//  SMBaseData.h
//  newsmth
//
//  Created by Maxwin on 13-6-9.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMBaseData : NSObject
- (id)initWithData:(NSDictionary *)data;
@property (strong, nonatomic) id dict;
@end

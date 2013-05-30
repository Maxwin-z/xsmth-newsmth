//
//  SMMessage.h
//  newsmth
//
//  Created by Maxwin on 13-5-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMMessage : NSObject
@property (assign, nonatomic) NSInteger code;
@property (strong, nonatomic) NSString *message;
- (id)initWithCode:(NSInteger)code message:(NSString *)message;
@end

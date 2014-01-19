//
//  SMCryptoUtil.h
//  TestCrypto
//
//  Created by damu on 1/19/14.
//  Copyright (c) 2014 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMCryptoUtil : NSObject
+(NSData *)AES128Encrypt:(NSString *)text;
+(NSString *)AES128Decrypt:(NSData *)data;
@end

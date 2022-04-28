//
//  SMUtils.h
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SMUtils : NSObject

+ (NSInteger)systemVersion;
+ (NSString *)systemVersionString;
+ (NSString *)appVersionString;

+ (BOOL)isPad;
+ (BOOL)isPortrait;

// unique format for sm
+ (NSString *)formatDate:(NSDate *)date;

+ (NSString *)encodeurl:(NSString *)url;

// stretch image at center
+ (UIImage *)stretchedImage:(UIImage *)image;

+ (UIColor *)reverseColor:(UIColor *)color;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString *)hexFromUIColor:(UIColor *)color;

+ (NSString *)formatSize:(unsigned long long)size;

+ (id)string2json:(NSString *)str;
+ (NSString *)json2string:(id)json;

+ (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label;

+ (BOOL)writeData:(NSData *)data toDocumentFolder:(NSString *)path;
+ (NSData *)readDataFromDocumentFolder:(NSString *)path;
+ (BOOL)fileExistsInDocumentFolder:(NSString *)path;
+ (void)savePhoto:(NSData*) dadata completionHandler:(void(^)(BOOL success, NSError * _Nullable error))block;
+ (BOOL)isGif:(NSData *)data;

+ (void)setIOS7ButtonStyle:(UIButton *)button;
+ (void)setTextFieldStyle:(UITextField *)textField;
+ (NSString *)gb2312Data2String:(NSData *)data;

+ (NSString *)documentPath;

+ (NSString *)trimHtmlTag:(NSString *)html;
+ (NSString *)generateUUID;
+ (NSString *)getSMUUID;
+ (NSString *)md5:(NSData *)data;
@end

@interface NSString (SMUtils)
-(CGSize) smSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)mode;

@end

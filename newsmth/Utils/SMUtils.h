//
//  SMUtils.h
//  newsmth
//
//  Created by Maxwin on 13-6-25.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMUtils : NSObject

+ (NSInteger)systemVersion;

// unique format for sm
+ (NSString *)formatDate:(NSDate *)date;

// stretch image at center
+ (UIImage *)stretchedImage:(UIImage *)image;

+ (void)trackEventWithCategory:(NSString *)category
                        action:(NSString *)action
                         label:(NSString *)label;

@end

@interface NSString (SMUtils)
-(CGSize) smSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)mode;
@end

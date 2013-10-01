//
//  XTimeLabel.m
//  newsmth
//
//  Created by Maxwin on 13-10-1.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XTimeLabel.h"

@implementation XTimeLabel

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setBeginTime:(NSDate *)beginTime
{
    _beginTime = beginTime;
    [self updateTime];
}

- (void)setFormatter:(NSString *)formatter
{
    _formatter = formatter;
    [self updateTime];
}

- (void)updateTime
{
    NSString *time = [self formatTime];
    if (_formatter != nil) {
        time = [NSString stringWithFormat:_formatter, time];
    }
    self.text = time;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTime) object:nil];
    [self performSelector:@selector(updateTime) withObject:nil afterDelay:10];
}

- (NSString *)formatTime
{
    NSTimeInterval elapsed = -[_beginTime timeIntervalSinceNow];
    if (elapsed < 10) {
        return @"刚刚";
    }
    if (elapsed < 60) {
        return @"<1分钟";
    }
    if (elapsed < 60 * 30) {
        return [NSString stringWithFormat:@"%d分钟前", (int)(elapsed / 60)];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (elapsed > 24 * 3600) {
        [formatter setDateFormat:@"yyyy/MM/dd"];
    } else {
        [formatter setDateFormat:@"HH:mm"];
    }
    return [formatter stringFromDate:_beginTime];
}

@end

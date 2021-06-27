//
//  SMEditActivity.m
//  newsmth
//
//  Created by Maxwin on 15/3/14.
//  Copyright (c) 2015年 nju. All rights reserved.
//

#import "SMAuthorActivity.h"
@interface SMAuthorActivity()
@property (nonatomic, strong) NSString *author;
@end

@implementation SMAuthorActivity

- (id)initWithAuthor:(NSString *)author
{
    self = [super init];
    _author = author;
    return self;
}

- (NSString *)activityTitle
{
    return [NSString stringWithFormat:@"查看用户[%@]", self.author];
}

- (NSString *)activityType
{
    return SMActivityAuthorActivity;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_user"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)performActivity
{
    [self activityDidFinish:YES];
}

@end

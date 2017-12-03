//
//  SMZanShangUtil.m
//  newsmth
//
//  Created by Maxwin on 03/12/2017.
//  Copyright © 2017 nju. All rights reserved.
//

#import "SMZanShangUtil.h"

#define USER_DEFAULT_OPEN_COUNT @"USER_DEFAULT_OPEN_COUNT"
#define USER_DEFAULT_DID_ZANSHANG @"USER_DEFAULT_DID_ZANSHANG"

#define OPEN_COUNT_THRESHOLD 10
#define VIEW_COUNT_THRESHOLD 10

@interface SMZanShangUtil ()
@property (strong, nonatomic) NSData *imageData;
@property (assign, nonatomic) NSInteger openCount;
@property (assign, nonatomic) NSInteger viewCount;
@property (assign, nonatomic) BOOL didZanShang;
@end

@implementation SMZanShangUtil
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SMZanShangUtil *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [SMZanShangUtil new];
        [_instance start];
    });
    return _instance;
}

- (void)start
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.didZanShang = [def boolForKey:USER_DEFAULT_DID_ZANSHANG];
    if (self.didZanShang) {
        return ;
    }

    self.openCount = [def integerForKey:USER_DEFAULT_OPEN_COUNT];
    self.viewCount = 0;
    [self loadZanShangImage];
}

- (void)loadZanShangImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://maxwin-z.github.io/xsmth/zanshang.md"];
        NSError *error = nil;
        NSString *imageUrl = [[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([imageUrl hasPrefix:@"https://"]) {
            NSString *filename = [NSString stringWithFormat:@"zanshang_%@", [imageUrl lastPathComponent]];
            NSData *data = [SMUtils readDataFromDocumentFolder:filename];
            if (data == nil) {
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                [SMUtils writeData:data toDocumentFolder:filename];
            }
            self.imageData = data;
            NSLog(@"zanshang image done");
        }
    });
}

- (void)addOpenCount
{
    ++self.openCount;
    [[NSUserDefaults standardUserDefaults] setInteger:self.openCount forKey:USER_DEFAULT_OPEN_COUNT];
}

- (void)addViewCount
{
    ++self.viewCount;

    if (!self.didZanShang
        && self.openCount > OPEN_COUNT_THRESHOLD
        && self.viewCount > VIEW_COUNT_THRESHOLD
        && self.imageData
        ) {
        NSLog(@"should zanshangzanshangzanshangzanshangzanshangzanshangzanshang");
    }
}

@end

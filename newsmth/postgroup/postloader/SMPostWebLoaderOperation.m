//
//  SMPostWebLoaderOperation.m
//  newsmth
//
//  Created by Maxwin on 14-3-28.
//  Copyright (c) 2014年 nju. All rights reserved.
//

#import "SMPostWebLoaderOperation.h"
#import "SMDBManager.h"

@interface SMPostWebLoaderOperation () <SMWebLoaderOperationDelegate>
@property (weak, nonatomic) id<SMWebLoaderOperationDelegate> originDelegate;
@property (strong, nonatomic) SMPost *post;
@property (assign, nonatomic) BOOL fromMobile;
@property (strong, nonatomic) SMWebLoaderOperation *loadOp;
@end


@implementation SMPostWebLoaderOperation

- (void)loadPost:(SMPost *)post fromMobile:(BOOL)m;
{
    self.post = post;
    self.fromMobile = m;
    [super enqueue];
}

- (void)main
{
    SMPost *post = self.post;
    [[SMDBManager instance] queryPost:post.pid board:post.board.name completed:^(SMPost *post_) {
        if (post_) {
            self->_data = post_;
            self->_isDone = YES;
            [self.originDelegate webLoaderOperationFinished:self];
        } else {
            NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbscon.php?bid=%@&id=%@", @(post.board.bid), @(post.pid)];
            if (self.fromMobile) {
                url = [NSString stringWithFormat:URL_PROTOCOL @"//m.newsmth.net/article/%@/single/%d/0",
                       post.board.name, post.pid];
            }
           
            self.loadOp = [SMWebLoaderOperation new];
            self.loadOp.delegate = self;
            [self.loadOp loadUrl:url withParser:@"bbscon,util_notice"];
        }
    }];
}

- (void)setDelegate:(id<SMWebLoaderOperationDelegate>)delegate
{
    [super setDelegate:self];
    self.originDelegate = delegate;
}

- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    self->_data = opt.data;
    SMPost *post = opt.data;
    [[SMDBManager instance] insertPost:post];
    self->_isDone = YES;
    [self.originDelegate webLoaderOperationFinished:self];
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    self->_isDone = YES;
    [self.originDelegate webLoaderOperationFail:self error:error];
}

- (void)dealloc
{
}


@end

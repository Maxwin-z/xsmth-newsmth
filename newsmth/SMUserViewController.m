//
//  SMUserViewController.m
//  newsmth
//
//  Created by Maxwin on 13-6-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMUserViewController.h"
#import "SMLoginViewController.h"
#import "UIButton+Custom.h"

@interface SMUserViewController ()<SMWebLoaderOperationDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelForUserInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonForLogout;

@property (strong, nonatomic) SMWebLoaderOperation *userInfoOp;
@property (strong, nonatomic) SMWebLoaderOperation *logoutOp;

@property (strong, nonatomic) SMUser *user;

@end

@implementation SMUserViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged) name:NOTIFICATION_ACCOUT object:nil];
    }
    return self;
}


- (void)dealloc
{
    [_userInfoOp cancel];
    [_logoutOp cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self accountChanged];
    
    [_buttonForLogout setButtonSMType:SMButtonTypeRed];
}

- (void)accountChanged
{
    if (_username == nil && [SMAccountManager instance].name == nil) {
        _labelForUserInfo.hidden = _buttonForLogout.hidden = YES;
        [self showLogin];
    } else {
        [_userInfoOp cancel];
        _userInfoOp = [[SMWebLoaderOperation alloc] init];
        _userInfoOp.delegate = self;
        
        NSString *username =  _username == nil ? [SMAccountManager instance].name : _username;
        self.title = username;
        
        NSString *url = [NSString stringWithFormat:@"http://www.newsmth.net/bbsqry.php?userid=%@", username];
        [_userInfoOp loadUrl:url withParser:@"bbsqry"];
    }
    
}

- (void)setUser:(SMUser *)user
{
    _user = user;
    _labelForUserInfo.text = user.info;
    
    [self hideLogin];
    
    _labelForUserInfo.hidden = NO;
    _buttonForLogout.hidden = _username != nil && ![_username isEqualToString:[SMAccountManager instance].name];
}

- (IBAction)onLogoutButtonClick:(id)sender
{
    [_logoutOp cancel];
    _logoutOp = [[SMWebLoaderOperation alloc] init];
    [_logoutOp loadUrl:@"http://m.newsmth.net/user/logout" withParser:nil];
    [SMUtils trackEventWithCategory:@"user" action:@"logout" label:[SMAccountManager instance].name];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
    self.user = opt.data;
}

- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
}

@end

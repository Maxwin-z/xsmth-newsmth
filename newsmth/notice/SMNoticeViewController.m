//
//  SMNoticeViewController.m
//  newsmth
//
//  Created by Maxwin on 13-7-30.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMNoticeViewController.h"
#import "SMMailViewController.h"
#import "SMAtMeViewController.h"
#import "SMReplyMeViewController.h"

static SMNoticeViewController *_instance;

@interface SMNoticeViewController ()<UITabBarDelegate>
@property (strong, nonatomic) NSArray *viewControllers;
@property (weak, nonatomic) IBOutlet UIView *viewForContainer;
@property (weak, nonatomic) IBOutlet UITabBar *tabbar;
@property (assign, nonatomic) NSInteger currentSelectIndex;

@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItemForMail;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItemForReply;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItemForAt;


@end

@implementation SMNoticeViewController

+ (SMNoticeViewController *)instance
{
    if (_instance == nil) {
        _instance = [[SMNoticeViewController alloc] init];
    }
    return _instance;
}
- (id)init
{
    if (_instance == nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountChanged) name:NOTIFICATION_ACCOUT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNoticeNotification) name:NOTIFICATION_NOTICE object:nil];

        _instance = self = [super initWithNibName:@"SMNoticeViewController" bundle:nil];
        _currentSelectIndex = -1;
    }
    return _instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SMMailViewController *mailVc = [[SMMailViewController alloc] init];
    SMAtMeViewController *atMeVc = [[SMAtMeViewController alloc] init];
    SMReplyMeViewController *replyVc = [[SMReplyMeViewController alloc] init];
    _viewControllers = @[mailVc, replyVc, atMeVc];
    
    self.currentSelectIndex = 0;
    
    [self onNoticeNotification]; 
}

- (void)setCurrentSelectIndex:(NSInteger)currentSelectIndex
{
    if (currentSelectIndex == _currentSelectIndex) {
        return ;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    
    UIView *v = [self viewControllerAtIndex:_currentSelectIndex].view;
    [v removeFromSuperview];
    
    _currentSelectIndex = currentSelectIndex;
    UIViewController *vc = [self viewControllerAtIndex:_currentSelectIndex];
    [_viewForContainer addSubview:vc.view];
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    vc.view.frame = _viewForContainer.bounds;
    
    self.title = vc.title;
    
    if (_currentSelectIndex >= 0 && _currentSelectIndex <= _tabbar.items.count) {
        self.tabbar.selectedItem = self.tabbar.items[_currentSelectIndex];
    }

}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (index >= 0 && index < _viewControllers.count) {
        return _viewControllers[index];
    }
    return nil;
}

- (void)accountChanged
{
    if ([SMAccountManager instance].isLogin) {
        self.tabbar.hidden = self.viewForContainer.hidden = NO;
        [self hideLogin];
        
        [SMUtils trackEventWithCategory:@"notice" action:@"enter" label:nil];
    } else {
        self.tabbar.hidden = self.viewForContainer.hidden = YES;
        [self showLogin];
    }
}

- (void)onNoticeNotification
{
    SMNotice *notice = [SMAccountManager instance].notice;
    _tabBarItemForMail.badgeValue = notice.mail > 0 ? @"信" : nil;
    _tabBarItemForReply.badgeValue = notice.reply > 0 ? [NSString stringWithFormat:@"%d", notice.reply] : nil;
    _tabBarItemForAt.badgeValue = notice.at > 0 ? [NSString stringWithFormat:@"%d", notice.at] : nil;
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger index = item.tag;
    self.currentSelectIndex = index;
}

@end

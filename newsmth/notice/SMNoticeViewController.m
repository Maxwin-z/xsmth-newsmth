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
    _viewControllers = @[mailVc, atMeVc, replyVc];
    
    self.currentSelectIndex = 0;
}

- (void)setCurrentSelectIndex:(NSInteger)currentSelectIndex
{
    if (currentSelectIndex == _currentSelectIndex) {
        return ;
    }
    
    UIView *v = [self viewAtIndex:currentSelectIndex];
    [v removeFromSuperview];
    
    _currentSelectIndex = currentSelectIndex;
    v = [self viewAtIndex:_currentSelectIndex];
    [_viewForContainer addSubview:v];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    v.frame = _viewForContainer.bounds;
    
    if (_currentSelectIndex >= 0 && _currentSelectIndex <= _tabbar.items.count) {
        self.tabbar.selectedItem = self.tabbar.items[_currentSelectIndex];
    }

}

- (UIView *)viewAtIndex:(NSInteger)index
{
    if (index >= 0 && index < _viewControllers.count) {
        return [_viewControllers[index] view];
    }
    return nil;
}

#pragma mark - UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger index = item.tag;
    self.currentSelectIndex = index;
}

@end

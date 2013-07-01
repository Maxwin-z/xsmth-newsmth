//
//  SMViewController.m
//  newsmth
//
//  Created by Maxwin on 13-5-29.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "SMLoginViewController.h"
#import "UIButton+Custom.h"

@interface SMViewController ()
@property (assign, nonatomic) SEL selectorAfterLogin;

@property (strong, nonatomic) IBOutlet UIView *viewForPopover;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForPopoverBg;
@property (weak, nonatomic) IBOutlet UILabel *labelForPoperoverMessage;

//@property (strong, nonatomic) SMLoginViewController *loginViewController;

@end

@implementation SMViewController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackedViewName = NSStringFromClass([self class]);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    // change back icon
//    if (self.navigationController.viewControllers.count > 1) {
//        UIButton *button = [UIButton buttonWithSMType:SMButtonTypeBack];
//        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//        [button addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
//        
//        self.navigationItem.leftBarButtonItem = backItem;
//        self.navigationItem.hidesBackButton = YES;
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toast:(NSString *)message
{
    UIView *window = [UIApplication sharedApplication].keyWindow;
    if (_viewForPopover == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SMViewControllerPopover" owner:self options:nil];
        _imageViewForPopoverBg.image = [_imageViewForPopoverBg.image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    }
    CGRect frame = window.bounds;
    frame.size.height -= _keyboardHeight;
    _viewForPopover.frame = frame;
    [window addSubview:_viewForPopover];
    
    _labelForPoperoverMessage.text = message;
    [self performSelector:@selector(hideToast) withObject:nil afterDelay:TOAST_DURTAION];
}

- (void)hideToast
{
    [_viewForPopover removeFromSuperview];
}

- (void)performSelectorAfterLogin:(SEL)aSelector
{
    SMLoginViewController *loginVc = [[SMLoginViewController alloc] init];
    [loginVc setAfterLoginTarget:self selector:aSelector];
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:loginVc];
    [self presentModalViewController:nvc animated:YES];
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onKeyboardDidShow:(NSNotification *)n
{
    NSDictionary* info = [n userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyboardHeight = kbSize.height;
}

- (void)onKeyboardDidHide:(NSNotification *)n
{
    _keyboardHeight = 0.0f;
}

@end

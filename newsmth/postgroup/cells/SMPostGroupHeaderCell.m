//
//  SMPostGroupHeaderCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupHeaderCell.h"
#import "UIButton+Custom.h"
#import "GADBannerView.h"
#import <iAd/iAd.h>

const CGFloat ADVIEW_HEIGHT = 50.0f;

@interface SMPostGroupHeaderCell ()<ADBannerViewDelegate, GADBannerViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForIndex;
@property (weak, nonatomic) IBOutlet UILabel *labelForDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonForReply;

@property (strong, nonatomic) UIView *viewForAdContainer;
@property (strong, nonatomic) GADBannerView *gAdView;
@property (strong, nonatomic) ADBannerView *iAdView;
@property (assign, nonatomic) BOOL isAdLoaded;
@end

@implementation SMPostGroupHeaderCell

+ (CGFloat)cellHeight:(SMPostItem *)item
{
    NSInteger gAdRatio = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_GADRATIO];
    NSInteger iAdRatio = [[NSUserDefaults standardUserDefaults] integerForKey:USERDEFAULTS_UPDATE_IADRATIO];
    
    if (item.index % 10 == 0 && !item.isAdGenerated) {
        item.isAdGenerated = YES;
        NSInteger rand = arc4random() % 100;
        if (rand < gAdRatio) {
            item.showGAd = YES;
        } else if (rand < gAdRatio + iAdRatio) {
            item.showIAd = YES;
        }
//        XLog_d(@"%@, %@, %@",@(rand), @(item.showGAd), @(item.showIAd));
    }
    
    return [self heightForTitle] + (item.showIAd || item.showGAd ? ADVIEW_HEIGHT : 0);
}

+ (CGFloat)heightForTitle
{
    CGFloat fontHeight = [SMConfig postFont].lineHeight;
    return fontHeight * 2 + 10.0f;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostGroupHeaderCell" owner:self options:nil];
//        _viewForCell.frame = self.contentView.bounds;
        
        CGRect frame = _viewForCell.frame;
        frame.size.height = [[self class] heightForTitle];
        frame.origin.y = self.contentView.frame.size.height - frame.size.height;
        _viewForCell.frame = frame;
        [self.contentView addSubview:_viewForCell];
        
        self.viewForAdContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, ADVIEW_HEIGHT)];
        self.viewForAdContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.viewForAdContainer];
    }
    return self;
}

- (void)setItem:(SMPostItem *)item
{
    _item = item;
    SMPost *post = item.post;
    
    NSString *author = post.author;
    if (post.nick.length > 0) {
        author = [NSString stringWithFormat:@"%@(%@)", post.author, post.nick];
    }
    
    [_buttonForAuthor setTitle:author forState:UIControlStateNormal];
    
//    _labelForIndex.text = [NSString stringWithFormat:@"#%d", item.index + 1];
    
    NSString *dateStr = @"";
    if (post.date > 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:post.date / 1000l]];
    }
    _labelForDate.text = [NSString stringWithFormat:@"#%@  %@", @(item.index + 1), dateStr];

    UIFont *font = [SMConfig postFont];
    _buttonForAuthor.titleLabel.font = font;
    _labelForDate.font = font;
    
    // use
    CGFloat fontHeight = font.lineHeight;
    CGRect frame = _buttonForAuthor.frame;
    frame.size.height = fontHeight;
    _buttonForAuthor.frame = frame;
    
    frame = _labelForDate.frame;
    frame.origin.y = CGRectGetMaxY(_buttonForAuthor.frame);
    frame.size.height = fontHeight;
    _labelForDate.frame = frame;
    
//    [_labelForIndex sizeToFit];
//    CGRect frame = _labelForDate.frame;
//    frame.origin.x = _labelForIndex.frame.origin.x + _labelForIndex.frame.size.width + 10.0f;
//    _labelForDate.frame = frame;
    
    // theme
    self.backgroundColor = [SMTheme colorForBackground];
    _labelForIndex.textColor = _labelForDate.textColor = [SMTheme colorForSecondary];
    [_buttonForAuthor setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];
    [_buttonForReply setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];

    UIImage *image = [_buttonForReply imageForState:UIControlStateNormal];
    if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [_buttonForReply setImage:image forState:UIControlStateNormal];
    [_buttonForReply setBackgroundImage:nil forState:UIControlStateNormal];

    //
    if (item.showGAd || item.showIAd) {
        if (item.showGAd && !self.gAdView) {
            self.gAdView = [[GADBannerView alloc] initWithFrame:self.viewForAdContainer.bounds];
            self.gAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.gAdView.adUnitID = @"a1530065d538e8a";
            [self.viewForAdContainer addSubview:self.gAdView];
            self.gAdView.rootViewController = self.viewController;
            [self.gAdView loadRequest:[GADRequest request]];
        }
        if (item.showIAd && !self.iAdView) {
            self.iAdView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
            self.iAdView.frame = self.viewForAdContainer.bounds;
            self.iAdView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.iAdView.delegate = self;
            [self.viewForAdContainer addSubview:self.iAdView];
        }
        self.viewForAdContainer.hidden = NO;
        if (self.isAdLoaded) {
            [self trackAd];
        }
    } else {
        self.viewForAdContainer.hidden = YES;
    }
}

- (IBAction)onReplyButtonClick:(id)sender
{
    [_delegate postGroupHeaderCellOnReply:_item.post];
}

- (IBAction)onUsernameClick:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(postGroupHeaderCellOnUsernameClick:)]) {
        [_delegate postGroupHeaderCellOnUsernameClick:_item.post.author];
    }
}

#pragma mark - ADBannerViewDelegate, GADBannerViewDelegate
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [SMUtils trackEventWithCategory:@"ad" action:@"apple_show" label:nil];
    return YES;
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView
{
    [SMUtils trackEventWithCategory:@"ad" action:@"admob_show" label:nil];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.isAdLoaded = YES;
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    self.isAdLoaded = YES;
}

- (void)setIsAdLoaded:(BOOL)isAdLoaded
{
    if (_isAdLoaded == NO) {    // 初次加载, 补计一次
        [self trackAd];
    }
    _isAdLoaded = isAdLoaded;
}

- (void)trackAd
{
    if (self.item.showGAd) {
        [SMUtils trackEventWithCategory:@"ad" action:@"admob" label:nil];
    }
    if (self.item.showIAd) {
        [SMUtils trackEventWithCategory:@"ad" action:@"apple" label:nil];
    }
}

@end

//
//  SMBoardCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-13.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMBoardCell.h"
#import "SMUtils.h"
#import <MMKV/MMKV.h>

static SMBoardCell *_instance;

@interface SMBoardCell ()
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForPostTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labelForReplyTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonForReplyAuthor;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForTop;

// v2.4 unread hint
@property (weak, nonatomic) IBOutlet UIImageView *imageViewForUnreadHint;
@end

@implementation SMBoardCell

+ (CGFloat)cellHeight:(SMPost *)post withWidth:(CGFloat)width
{
    if (_instance == nil) {
        _instance = [[SMBoardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    CGRect frame = _instance.frame;
    frame.size.width = width;
    _instance.frame = frame;
    [_instance layoutIfNeeded];
        
    CGFloat heightExpectTitle = _instance.viewForCell.frame.size.height - _instance.labelForTitle.frame.size.height;
    NSString *title = [NSString stringWithFormat:@"%@(%d)", post.title, post.replyCount];
    CGFloat titleHeight = [title smSizeWithFont:[SMConfig listFont] constrainedToSize:CGSizeMake(_instance.labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:_instance.labelForTitle.lineBreakMode].height;

    return titleHeight + heightExpectTitle + 1;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.selectedBackgroundView = selectedBackgroundView;
        [[NSBundle mainBundle] loadNibNamed:@"SMBoardCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
    }
    return self;
}

- (NSString *)keyForUser:(NSString *)username {
    return [NSString stringWithFormat:@"tags_%@", username];
}

- (void)setPost:(SMPost *)post
{
    _post = post;
    NSString *title = _post.title;
    if (_post.replyCount > 0) {
        title = [NSString stringWithFormat:@"%@(%d)", _post.title, _post.replyCount];
    }
    _labelForTitle.text = title;
    _labelForTitle.font = [SMConfig listFont];
    _labelForPostTime.text = [SMUtils formatDate:[NSDate dateWithTimeIntervalSince1970:_post.date / 1000]];
    
    _labelForReplyTime.text = [SMUtils formatDate:[NSDate dateWithTimeIntervalSince1970:_post.replyDate / 1000]];
//    [_buttonForAuthor setTitle:_post.author forState:UIControlStateNormal];
    NSMutableAttributedString *authorTitle = [[NSMutableAttributedString alloc] init];
    [authorTitle appendAttributedString: [[NSAttributedString alloc] initWithString:_post.author attributes:@{
           NSForegroundColorAttributeName: [SMTheme colorForSecondary]
    }]];
    // load author
    NSString *userString = [[MMKV defaultMMKV] getStringForKey:[self keyForUser:_post.author]];
    while (true) {
        if (userString == nil) break;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[userString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        if (json == nil) break;
        NSDictionary *info = json[@"value"];
        @try {
            SMUserTag *userTag = [[SMUserTag alloc] initWithJSON:info];
            XLog_d(@"%@", userTag);
            [userTag.tags enumerateObjectsUsingBlock:^(SMTag* tag, NSUInteger idx, BOOL * _Nonnull stop) {
               NSString *hex = tag.color;
               if (hex.length == 7) {
                   UIColor *color = [SMUtils colorFromHexString:hex];
                   [authorTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"■" attributes:@{
                       NSForegroundColorAttributeName: color,
                       NSFontAttributeName: [UIFont systemFontOfSize:10]
                   }]];
               }
            }];
        } @catch (NSException *exception) {} @finally {}
        break;
    }
    
    [_buttonForAuthor setAttributedTitle:authorTitle forState:UIControlStateNormal];
    if (_post.replyAuthor) {
        [_buttonForReplyAuthor setTitle:_post.replyAuthor forState:UIControlStateNormal];
    }
    
    _imageViewForTop.hidden = !_post.isTop;
    
    _buttonForAuthor.enabled = _buttonForReplyAuthor.enabled = [SMConfig enableUserClick];
    
    _buttonForReplyAuthor.hidden = ![SMConfig enableShowReplyAuthor] || _post.replyAuthor == nil;
    _labelForReplyTime.hidden = ![SMConfig enableShowReplyAuthor] || _post.replyDate == 0;
    
    self.backgroundColor = [SMTheme colorForBackground];
    self.selectedBackgroundView.backgroundColor = [SMTheme colorForHighlightBackground];
    _labelForTitle.textColor = [SMTheme colorForPrimary];
    _labelForPostTime.textColor = _labelForReplyTime.textColor = [SMTheme colorForSecondary];
    
//    [_buttonForAuthor setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];
    [_buttonForReplyAuthor setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];
    [_buttonForAuthor setTitleColor:[SMTheme colorForSecondary] forState:UIControlStateDisabled];
    [_buttonForReplyAuthor setTitleColor:[SMTheme colorForSecondary] forState:UIControlStateDisabled];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 重置title位置。由于置顶cell会返回高度10，导致title auto adjust错乱
    CGRect frame = _labelForTitle.frame;
    frame.origin = _instance.labelForTitle.frame.origin;
    frame.size.width = _instance.labelForTitle.frame.size.width;
    frame.size.height = self.frame.size.height - (_instance.frame.size.height - _instance.labelForTitle.frame.size.height);
    _labelForTitle.frame = frame;
    
    // fix position
    __block CGFloat left = _labelForPostTime.frame.origin.x;
    CGFloat centerY = _labelForPostTime.center.y;
    [@[_labelForPostTime, _buttonForAuthor, _labelForReplyTime, _buttonForReplyAuthor]
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         UIView *view = obj;
         [view sizeToFit];
         
         CGRect frame = view.frame;
         frame.origin.x = left;
         view.frame = frame;
         view.center = CGPointMake(view.center.x, centerY);
         
         left += frame.size.width + 10.0f;   //padding
     }];
    
    // v2.4 show unread hint
    NSString *unreadHintImage;
    if (self.post.readCount == -1) {
        unreadHintImage = @"unread";
    } else if (self.post.replyCount == self.post.readCount) {
        // all read
    //    unreadHintImage = @"unread_none";
        unreadHintImage = nil;  // v2.4.1 移除未读提示
    } else {
        unreadHintImage = @"unread_half";
    }
    if (self.post.isTop) { // 置底贴不显示
        unreadHintImage = nil;
    }
    self.imageViewForUnreadHint.image = [UIImage imageNamed:unreadHintImage];
}

- (IBAction)onUsernameClick:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(boardCellOnUserClick:)]) {
        [_delegate boardCellOnUserClick:button.titleLabel.text];
    }
}

@end

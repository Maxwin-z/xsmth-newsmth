//
//  SMPostGroupContentCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupContentCell.h"

static SMPostGroupContentCell *_instance;

@interface SMPostGroupContentCell ()<UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (strong, nonatomic) IBOutlet UILabel *labelForContent;
@property (strong, nonatomic) IBOutlet UIWebView *webViewForContent;
@property (weak, nonatomic) IBOutlet UIView *viewForActions;
@property (weak, nonatomic) IBOutlet UIButton *buttonForReply;
@property (weak, nonatomic) IBOutlet UIButton *buttonForForward;
@property (weak, nonatomic) IBOutlet UIButton *buttonForSearch;
@property (weak, nonatomic) IBOutlet UIButton *buttonForMore;
@end

@implementation SMPostGroupContentCell

+ (SMPostGroupContentCell *)instance
{
    if (_instance == nil) {
        _instance = [[SMPostGroupContentCell alloc] init];
    }
    return _instance;
}

+ (CGFloat)cellHeight:(SMPost *)post withWidth:(CGFloat)width
{
    SMPostGroupContentCell *cell = [self instance];
    CGRect frame = cell.frame;
    frame.size.width = width;
    cell.frame = frame;
    
    [cell layoutIfNeeded];
    
    CGFloat heightExceptContent = cell.viewForCell.frame.size.height - cell.labelForContent.frame.size.height;
    cell.labelForContent.font = [SMConfig postFont];
    CGFloat contentHeight = [post.content smSizeWithFont:cell.labelForContent.font constrainedToSize:CGSizeMake(cell.labelForContent.frame.size.width, CGFLOAT_MAX) lineBreakMode:cell.labelForContent.lineBreakMode].height;
    return heightExceptContent + contentHeight + 1;
}

- (void)dealloc
{
    _webViewForContent.delegate = nil;
    _webViewForContent = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"SMPostGroupContentCell" owner:self options:nil];
        _viewForCell.frame = self.contentView.bounds;
        [self.contentView addSubview:_viewForCell];
        
        _webViewForContent.scrollView.scrollEnabled = NO;
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeGesture];
    }
    return self;
}

- (void)onSwipeGesture:(UISwipeGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationOfTouch:0 inView:self];
    XLog_d(@"%@", NSStringFromCGPoint(point));
    
    CGRect frame = self.viewForActions.frame;
    frame.origin.y = MAX(0, point.y - frame.size.height / 2);
    self.viewForActions.frame = frame;
    self.viewForActions.hidden = NO;
}

- (void)hideActionView
{
    self.viewForActions.hidden = YES;
}

- (NSString *)color2hex:(UIColor *)color
{
    CGFloat rf, gf, bf, af;
    [color getRed:&rf green:&gf blue: &bf alpha: &af];

    int r = (int)(255.0 * rf);
    int g = (int)(255.0 * gf);
    int b = (int)(255.0 * bf);
    
    return [NSString stringWithFormat:@"#%02x%02x%02x",r,g,b];
}

- (NSString *)generateCSS
{
NSString *tpl =
@"body {\
    margin:0;\
    padding: 10px;\
    font-size:{fontSize}px;\
    font-family: \"{fontFamily}\";\
    line-height:{lineHeight}px;\
    background-color:{backgroundColor};\
    color:{textColor};\
}"
    
"a, a:visited {\
    text-decoration:none;\
    color:{tintColor};\
    display: inline-block;\
    border-bottom: 1px dashed {tintColor}\
}"
    
".q {\
    color:{quoteColor};\
}"
    
"a.origin_link {\
    display:block; line-height: 25px; font-size: 14px;\
    width: 80%; margin: 10px auto; text-align:center;\
    border: 1px solid {tintColor}; \
    border-radius: 5px 5px 5px 5px;\
}";
    
    UIFont *font = [SMConfig postFont];

    NSString *fontSize = [NSString stringWithFormat:@"%d", (int)font.pointSize];
    NSString *fontFamily = font.fontName;
    NSString *lineHeight = [NSString stringWithFormat:@"%d", (int)(font.lineHeight * 1.2)];
    NSString *backgroundColor = [self color2hex:[SMTheme colorForBackground]];
    NSString *textColor = [self color2hex:[SMTheme colorForPrimary]];
    NSString *tintColor = [self color2hex:[SMTheme colorForTintColor]];
    NSString *quoteColor = [self color2hex:[SMTheme colorForQuote]];
    
    NSString *css = tpl;
    css = [css stringByReplacingOccurrencesOfString:@"{fontSize}" withString:fontSize];
    css = [css stringByReplacingOccurrencesOfString:@"{fontFamily}" withString:fontFamily];
    css = [css stringByReplacingOccurrencesOfString:@"{lineHeight}" withString:lineHeight];
    css = [css stringByReplacingOccurrencesOfString:@"{backgroundColor}" withString:backgroundColor];
    css = [css stringByReplacingOccurrencesOfString:@"{textColor}" withString:textColor];
    css = [css stringByReplacingOccurrencesOfString:@"{tintColor}" withString:tintColor];
    css = [css stringByReplacingOccurrencesOfString:@"{quoteColor}" withString:quoteColor];
    
    return css;
}

- (NSString *)formatContent:(NSString *)content
{
    NSMutableString *html = [[NSMutableString alloc] init];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    for (int i = 0; i != lines.count; ++i) {
        NSString *line = lines[i];
        if (line.length == 0) {  // space line
            line = @" ";
        }
        NSString *color = [self color2hex:[SMTheme colorForPrimary]];
        if ([line hasPrefix:@":"]) {
            color = [self color2hex:[SMTheme colorForQuote]];
        }
        line = [line stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        line = [line stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        line = [line stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        line = [line stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"];
        
        [html appendFormat:@"<div style='color:%@'>%@<br /></div>", color, line];
    }
    return html;
}

- (NSString *)generateHtml:(BOOL)clip
{
    NSString *content = self.post.content;
    NSInteger maxLength = 1000;
    if (content.length > maxLength) {
        NSString *ratio = [NSString stringWithFormat:@"%d%%", (int)(maxLength * 100.0f / content.length)];

        NSString *head = [content substringToIndex:maxLength];
        NSString *tail = [content substringFromIndex:maxLength];

        if (clip) {
            NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/article/%@/single/%d/0",
                             self.post.board.name, self.post.pid];
            content = [NSString stringWithFormat:@"%@ <a class=\"origin_link\" href=\"xsmth://fullpost?url=%@\">原文过长，已加载%@<br />点击查看全部</a>", head, url, ratio];
        } else {
            content = [NSString stringWithFormat:@"%@<a name=\"tail\"></a>%@", head, tail];
        }
    }
    NSString *body = [NSString stringWithFormat:@"<html><style type=\"text/css\">%@</style><body>%@</body></html>", [self generateCSS], [self formatContent:content]];
    return body;
}

- (void)setPost:(SMPost *)post withOptimize:(BOOL)optimizeForIP4
{
    _post = post;
    
    self.backgroundColor = [SMTheme colorForBackground];
    if (optimizeForIP4) {
        // clear labels
        int contentLabelTag = 2014;
        for (int i = (int)(self.labelForContent.superview.subviews.count) - 1; i >= 0; --i) {
            UIView *v = self.labelForContent.superview.subviews[i];
            if (v.tag == contentLabelTag) {
                [v removeFromSuperview];
            }
        }
        
        // add labels
        CGFloat x = self.labelForContent.frame.origin.x;
        CGFloat y = self.labelForContent.frame.origin.y;
        NSArray *lines = [self.post.content componentsSeparatedByString:@"\n"];
        for (int i = 0; i != lines.count; ++i) {
            NSString *line = lines[i];
            if (line.length == 0) {  // space line
                line = @" ";
            }
            UIColor *color = [SMTheme colorForPrimary];
            if ([line hasPrefix:@":"]) {
                color = [SMTheme colorForQuote];
            }
            UILabel *label = [[UILabel alloc] init];
            label.font = [SMConfig postFont];
            label.text = line;
            label.textColor = color;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 0;
            
            CGSize size = [line smSizeWithFont:label.font constrainedToSize:CGSizeMake(self.labelForContent.frame.size.width, CGFLOAT_MAX) lineBreakMode:label.lineBreakMode];
            CGRect frame = CGRectMake(x, y, size.width, size.height);
            label.frame = frame;
            label.tag = contentLabelTag;
            [self.labelForContent.superview insertSubview:label belowSubview:self.labelForContent];
            
            y += size.height;
        }
        self.labelForContent.hidden = YES;
        
//        self.labelForContent.text = _post.content;
//        self.labelForContent.textColor = [SMTheme colorForPrimary];
//        self.labelForContent.font = [SMConfig postFont];
        [self.webViewForContent removeFromSuperview];
    } else {
        NSString *body = [self generateHtml:YES];
        [_webViewForContent loadHTMLString:body baseURL:nil];
        [self.labelForContent removeFromSuperview];
    }
    
    [@[_buttonForReply, _buttonForForward, _buttonForSearch, _buttonForMore] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = obj;
        [btn setTitleColor:[SMTheme colorForTintColor] forState:UIControlStateNormal];
        
        UIImage *image = [btn imageForState:UIControlStateNormal];
        if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        [btn setImage:image forState:UIControlStateNormal];
        [btn setBackgroundImage:nil forState:UIControlStateNormal];
        
        self.viewForActions.backgroundColor = [SMUtils reverseColor:[SMTheme colorForBackground]];
    }];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    if (height < 1) {
        height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
    }
    [_delegate postGroupContentCell:self heightChanged:height];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return YES;
    }
    XLog_d(@"%@", request.URL.absoluteString);
    
    if ([request.URL.absoluteString hasPrefix:@"xsmth://fullpost"]) {
        [_delegate postGroupContentCell:self fullHtml:[self generateHtml:NO]];
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(postGroupContentCell:shouldLoadUrl:)]) {
        [_delegate postGroupContentCell:self shouldLoadUrl:request.URL];
    }
    return NO;
}

#pragma mark - Events
- (IBAction)onReplyButtonClick:(id)sender
{
    [_delegate postGroupContentCellOnReply:self];
}

- (IBAction)onForwardButtonClick:(id)sender
{
    [_delegate postGroupContentCellOnForward:self];
}

- (IBAction)onSearchButtonClick:(id)sender
{
    [_delegate postGroupContentCellOnSearch:self];
}

- (IBAction)onMoreButtonClick:(id)sender
{
    [_delegate postGroupContentCellOnMoreAction:self];
}

@end

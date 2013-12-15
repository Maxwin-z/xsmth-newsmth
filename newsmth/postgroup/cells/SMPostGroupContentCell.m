//
//  SMPostGroupContentCell.m
//  newsmth
//
//  Created by Maxwin on 13-6-10.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMPostGroupContentCell.h"

static SMPostGroupContentCell *_instance;

@interface SMPostGroupContentCell ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *viewForCell;
@property (strong, nonatomic) IBOutlet UILabel *labelForContent;    // unused
@property (weak, nonatomic) IBOutlet UIWebView *webViewForContent;
@end

@implementation SMPostGroupContentCell

+ (SMPostGroupContentCell *)instance
{
    if (_instance == nil) {
        _instance = [[SMPostGroupContentCell alloc] init];
    }
    return _instance;
}

+ (CGFloat)cellHeight:(SMPost *)post
{
    SMPostGroupContentCell *cell = [self instance];
    CGFloat heightExceptContent = cell.viewForCell.frame.size.height - cell.labelForContent.frame.size.height;
    CGFloat contentHeight = [post.content smSizeWithFont:cell.labelForContent.font constrainedToSize:CGSizeMake(cell.labelForContent.frame.size.width, CGFLOAT_MAX) lineBreakMode:cell.labelForContent.lineBreakMode].height;
    return heightExceptContent + contentHeight;
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
    }
    return self;
}

- (NSString *)color2hex:(UIColor *)color
{
    CGFloat rf, gf, bf, af;
    [color getRed:&rf green:&gf blue: &bf alpha: &af];

    int r = (int)(255.0 * rf);
    int g = (int)(255.0 * gf);
    int b = (int)(255.0 * bf);
    
    return [NSString stringWithFormat:@"%02x%02x%02x",r,g,b];
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
        [html appendFormat:@"<div style='color:%@'>%@</div>", color, line];
    }
    return html;
}

- (void)setPost:(SMPost *)post
{
    _post = post;
    UIFont *font = [SMConfig postFont];
    NSString *body = [NSString stringWithFormat:@"<html><body style='margin:0; padding: 10px; font-size: %dpx;font-family: %@;line-height:%dpx;background-color:%@'>%@</body></html>", (int)font.pointSize, font.fontName, (int)(font.lineHeight * 1.2), [self color2hex:[SMTheme colorForBackground]], [self formatContent:post.content]];
    [_webViewForContent loadHTMLString:body baseURL:nil];
    
    self.backgroundColor = [SMTheme colorForBackground];
    _labelForContent.textColor = [SMTheme colorForPrimary];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] floatValue];
    [_delegate postGroupContentCell:self heightChanged:height];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return YES;
    }
    XLog_d(@"%@", request.URL.absoluteString);
    if ([_delegate respondsToSelector:@selector(postGroupContentCell:shouldLoadUrl:)]) {
        [_delegate postGroupContentCell:self shouldLoadUrl:request.URL];
    }
    return NO;
}


@end

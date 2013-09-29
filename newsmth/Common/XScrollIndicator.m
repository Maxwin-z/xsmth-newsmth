//
//  XScrollIndicator.m
//  HelloScrollIndicator
//
//  Created by Maxwin on 13-9-27.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "XScrollIndicator.h"

@implementation XScrollIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _normalFont = [UIFont systemFontOfSize:12.0f];
        _highlightFont = [UIFont systemFontOfSize:25.0f];
        _selectedIndex = 0;
        self.backgroundColor = SMRGB(0xf0, 0xf0, 0xff);
    }
    return self;
}

- (void)setTitles:(NSArray *)titles
{
    _titles = titles;
    [self makeup];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex >= 0 && selectedIndex < self.titles.count && _selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [self makeup];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)makeup
{
    if (_titles.count < 1) return ;
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    XLog_d(@"%d", _selectedIndex);
    
    CGFloat totalHeight = self.bounds.size.height;
    
    CGFloat itemHeight = [self heightForFont:_normalFont];
    CGFloat highlightHeight = [self heightForFont:_highlightFont];
    
    int count = _titles.count;
    int maxAvailCount = (totalHeight - highlightHeight) / itemHeight;
    if (_selectedIndex == 0 || _selectedIndex == count - 1) {
        ++maxAvailCount;
    }
    
    NSArray *availTitles = _titles;
    __block NSInteger tmpSelectedIndex = _selectedIndex;
    if (count > maxAvailCount && count > 2) {    // 不能够容纳所以的项目，按固定间距挑选
        // 0, selectedIndex, n-1 必选, ids用于存储被选中的id（这些id会被全部选择或者剔除）
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        // 选择较少的一方
        BOOL include = YES;
        NSInteger selectedCount = maxAvailCount - 2;
        if (maxAvailCount > count / 2) {
            include = NO;
            selectedCount = count - maxAvailCount - 2;
        }
        
        NSInteger leftCount = _selectedIndex * selectedCount / count;
        if (_selectedIndex < 2) {
            leftCount = 0;
        }
        if (count - 1 - _selectedIndex < 2) {
            leftCount = selectedCount;
        }
        
        NSInteger rightCount = selectedCount - leftCount;
        
        // 从 (0, _selectedIndex) 中选择 leftCount个
        NSArray *leftIds = [self pickup:0 end:_selectedIndex count:leftCount];
        NSArray *rightIds = [self pickup:_selectedIndex end:count - 1 count:rightCount];
        [ids addObjectsFromArray:leftIds];
        [ids addObjectsFromArray:rightIds];
        NSLog(@"(%d, e%d), (%d, e%d), %d", leftIds.count, leftCount, rightIds.count, rightCount, _selectedIndex);
        NSLog(@"%d      %@", ids.count, [ids componentsJoinedByString:@","]);
        
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        [_titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == _selectedIndex) {
                tmpSelectedIndex = tmp.count;
            }
            
            if (idx == 0 || idx == count - 1 || idx == _selectedIndex) {
                [tmp addObject:obj];
            } else if ((include && [ids containsObject:@(idx)]) ||
                (!include && ![ids containsObject:@(idx)])) {
                [tmp addObject:obj];
            }
        }];
        availTitles = tmp;
    } else {
        itemHeight = (totalHeight - highlightHeight) / (count - 1);
    }
    
    __block CGFloat x = 0, y = 0;
    [availTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *title = obj;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100.0f, idx == tmpSelectedIndex ? highlightHeight : itemHeight)];
        label.text = title;
        label.font = idx == tmpSelectedIndex ? _highlightFont : _normalFont;
        label.textColor = idx == tmpSelectedIndex ? [UIColor blueColor] : [UIColor blackColor];
        
        [self addSubview:label];
        y += label.frame.size.height;
    }];
}

- (CGFloat)heightForFont:(UIFont *)font
{
    NSDictionary * attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGSize sbSize = [@"TEST" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return ceilf(sbSize.height);
}

- (NSArray *)pickup:(NSInteger)start end:(NSInteger)end count:(NSInteger)count
{
    NSInteger step = ceilf((end - start) / (count + 1.0));
    if (step * (count + 1) > (end - start) && step > 1) {
        --step;
    }
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (int i = start + step; i < end && count-- > 0; i += step) {
        [res addObject:@(i)];
    }
    return res;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    _isDragging = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
//    NSLog(@"%@", NSStringFromCGPoint(point));
    CGFloat y = point.y;
    self.selectedIndex = (int)(y * self.titles.count / self.bounds.size.height);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self endTouch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self endTouch];
}

- (void)endTouch
{
    _isDragging = NO;
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}

/*
 function pickup (arr, count) {
 var step = Math.ceil(arr.length / (count + 1));
 var start = step;
 var res = [];
 for (i = start; i < arr.length && count-- > 0; i += step) {
 res.push(arr[i]);
 }
 
 console.log(res);
 }
*/
@end

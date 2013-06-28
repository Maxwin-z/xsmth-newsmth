#import "SMData.h"

@implementation SMPostGroup
- (int)bid
{
	return [[self.dict objectForKey:@"bid"] intValue];
}

- (void)setBid:(int)bid_
{
	[self.dict setInteger:bid_ forKey:@"bid"];
}

- (int)tpage
{
	return [[self.dict objectForKey:@"tpage"] intValue];
}

- (void)setTpage:(int)tpage_
{
	[self.dict setInteger:tpage_ forKey:@"tpage"];
}

- (NSString *)title
{
	return [self.dict objectForKey:@"title"];
}

- (void)setTitle:(NSString *)title_
{
	[self.dict setObject:title_ forKey:@"title"];
}

- (NSArray *)posts
{
	NSArray *objs = [self.dict objectForKey:@"posts"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
}

- (void)setPosts:(NSArray *)posts_
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:posts_.count];
    for (int i = 0; i != posts_.count; ++i) {
        [arr addObject:[posts_[i] dict]];
    }
    [self.dict setObject:arr forKey:@"posts"];
}

@end
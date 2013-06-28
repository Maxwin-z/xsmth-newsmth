#import "SMData.h"

@implementation SMBoard
- (NSString *)name
{
	return [self.dict objectForKey:@"name"];
}

- (void)setName:(NSString *)name_
{
	[self.dict setObject:name_ forKey:@"name"];
}

- (NSString *)cnName
{
	return [self.dict objectForKey:@"cnName"];
}

- (void)setCnName:(NSString *)cnName_
{
	[self.dict setObject:cnName_ forKey:@"cnName"];
}

- (int)bid
{
	return [[self.dict objectForKey:@"bid"] intValue];
}

- (void)setBid:(int)bid_
{
	[self.dict setInteger:bid_ forKey:@"bid"];
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
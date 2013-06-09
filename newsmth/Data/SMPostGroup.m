#import "SMPostGroup.h"

@implementation SMPostGroup
- (int)bid
{
	return [[self.dict objectForKey:@"bid"] intValue];
}

- (int)tpage
{
	return [[self.dict objectForKey:@"tpage"] intValue];
}

- (NSString *)title
{
	return [self.dict objectForKey:@"title"];
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

@end
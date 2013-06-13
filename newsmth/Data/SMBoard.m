#import "SMBoard.h"

@implementation SMBoard
- (NSString *)name
{
	return [self.dict objectForKey:@"name"];
}

- (NSString *)cnName
{
	return [self.dict objectForKey:@"cnName"];
}

- (int)bid
{
	return [[self.dict objectForKey:@"bid"] intValue];
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
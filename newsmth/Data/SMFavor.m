#import "SMFavor.h"

@implementation SMFavor
- (NSArray *)boards
{
	NSArray *objs = [self.dict objectForKey:@"boards"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
}

@end
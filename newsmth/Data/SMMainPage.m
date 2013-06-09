#import "SMMainPage.h"

@implementation SMMainPage
- (NSArray *)sections
{
	NSArray *objs = [self.dict objectForKey:@"sections"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
}

@end
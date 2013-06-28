#import "SMData.h"

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

- (void)setSections:(NSArray *)sections_
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:sections_.count];
    for (int i = 0; i != sections_.count; ++i) {
        [arr addObject:[sections_[i] dict]];
    }
    [self.dict setObject:arr forKey:@"sections"];
}

@end
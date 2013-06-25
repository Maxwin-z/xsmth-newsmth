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

- (void)setBoards:(NSArray *)boards_
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:boards_.count];
    for (int i = 0; i != boards_.count; ++i) {
        [arr addObject:[boards_[i] dict]];
    }
    [self.dict setObject:arr forKey:@"boards"];
}

@end
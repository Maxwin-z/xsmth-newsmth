#import "SMData.h"

@implementation SMBoardList
- (NSArray *)items
{
	NSArray *objs = [self.dict objectForKey:@"items"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
}

- (void)setItems:(NSArray *)items_
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:items_.count];
    for (int i = 0; i != items_.count; ++i) {
        [arr addObject:[items_[i] dict]];
    }
    [self.dict setObject:arr forKey:@"items"];
}

@end
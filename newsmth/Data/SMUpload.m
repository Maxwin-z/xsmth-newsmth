#import "SMData.h"

@implementation SMUpload
- (int)act
{
	return [[self.dict objectForKey:@"act"] intValue];
}

- (void)setAct:(int)act_
{
	[self.dict setValue:@(act_) forKey:@"act"];
}

- (NSString *)message
{
	return [self.dict objectForKey:@"message"];
}

- (void)setMessage:(NSString *)message_
{
	[self.dict setObject:message_ forKey:@"message"];
}

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

- (int)leftCount
{
	return [[self.dict objectForKey:@"leftCount"] intValue];
}

- (void)setLeftCount:(int)leftCount_
{
	[self.dict setValue:@(leftCount_) forKey:@"leftCount"];
}

- (int)leftSize
{
	return [[self.dict objectForKey:@"leftSize"] intValue];
}

- (void)setLeftSize:(int)leftSize_
{
	[self.dict setValue:@(leftSize_) forKey:@"leftSize"];
}

@end
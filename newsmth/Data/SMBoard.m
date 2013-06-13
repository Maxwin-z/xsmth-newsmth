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

@end
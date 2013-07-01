#import "SMData.h"

@implementation SMUser
- (NSString *)info
{
	return [self.dict objectForKey:@"info"];
}

- (void)setInfo:(NSString *)info_
{
	[self.dict setObject:info_ forKey:@"info"];
}

@end
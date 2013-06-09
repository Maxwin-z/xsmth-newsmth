#import "SMAttach.h"

@implementation SMAttach
- (NSString *)name
{
	return [self.dict objectForKey:@"name"];
}

- (int)len
{
	return [[self.dict objectForKey:@"len"] intValue];
}

- (int)pos
{
	return [[self.dict objectForKey:@"pos"] intValue];
}

@end
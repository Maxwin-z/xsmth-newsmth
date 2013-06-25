#import "SMAttach.h"

@implementation SMAttach
- (NSString *)name
{
	return [self.dict objectForKey:@"name"];
}

- (void)setName:(NSString *)name_
{
	[self.dict setObject:name_ forKey:@"name"];
}

- (int)len
{
	return [[self.dict objectForKey:@"len"] intValue];
}

- (void)setLen:(int)len_
{
	[self.dict setInteger:len_ forKey:@"len"];
}

- (int)pos
{
	return [[self.dict objectForKey:@"pos"] intValue];
}

- (void)setPos:(int)pos_
{
	[self.dict setInteger:pos_ forKey:@"pos"];
}

@end
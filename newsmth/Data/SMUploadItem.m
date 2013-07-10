#import "SMData.h"

@implementation SMUploadItem
- (NSString *)name
{
	return [self.dict objectForKey:@"name"];
}

- (void)setName:(NSString *)name_
{
	[self.dict setObject:name_ forKey:@"name"];
}

- (NSString *)key
{
	return [self.dict objectForKey:@"key"];
}

- (void)setKey:(NSString *)key_
{
	[self.dict setObject:key_ forKey:@"key"];
}

@end
#import "SMData.h"

@implementation SMResult
- (int)code
{
	return [[self.dict objectForKey:@"code"] intValue];
}

- (void)setCode:(int)code_
{
	[self.dict setValue:@(code_) forKey:@"code"];
}

- (NSString *)message
{
	return [self.dict objectForKey:@"message"];
}

- (void)setMessage:(NSString *)message_
{
	[self.dict setObject:message_ forKey:@"message"];
}

@end
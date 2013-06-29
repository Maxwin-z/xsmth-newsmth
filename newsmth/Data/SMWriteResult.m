#import "SMData.h"

@implementation SMWriteResult
- (BOOL)success
{
	return [[self.dict objectForKey:@"success"] boolValue];
}

- (void)setSuccess:(BOOL)success_
{
	[self.dict setValue:@(success_) forKey:@"success"];
}

@end
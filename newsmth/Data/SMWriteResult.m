#import "SMWriteResult.h"

@implementation SMWriteResult
- (BOOL)success
{
	return [[self.dict objectForKey:@"success"] boolValue];
}

- (void)setSuccess:(BOOL)success_
{
	[self.dict setBool:success_ forKey:@"success"];
}

@end
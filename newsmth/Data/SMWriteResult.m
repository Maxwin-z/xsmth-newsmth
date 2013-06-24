#import "SMWriteResult.h"

@implementation SMWriteResult
- (BOOL)success
{
	return [[self.dict objectForKey:@"success"] boolValue];
}

@end
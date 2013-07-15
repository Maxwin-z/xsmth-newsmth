#import "SMData.h"

@implementation SMWriteResult
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_success = [[dict objectForKey:@"success"] boolValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_success) forKey:@"success"];
	return dict;
}
@end
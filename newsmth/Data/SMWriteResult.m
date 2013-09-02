#import "SMData.h"

@implementation SMWriteResult
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_success = [[dict objectForKey:@"success"] boolValue];

	_message = [dict objectForKey:@"message"];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_success) forKey:@"success"];

	if (_message != nil) {
		[dict setObject:_message forKey:@"message"];
	}
	return dict;
}
@end
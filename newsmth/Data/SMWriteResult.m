#import "SMData.h"

@implementation SMWriteResult
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_success = [[dict objectForKey:@"success"] boolValue];

	id message = [dict objectForKey:@"message"];
	if (message != [NSNull null]) {
		_message = message;
	}
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
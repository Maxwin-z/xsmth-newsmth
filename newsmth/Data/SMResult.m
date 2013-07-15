#import "SMData.h"

@implementation SMResult
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_code = [[dict objectForKey:@"code"] intValue];

	_message = [dict objectForKey:@"message"];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_code) forKey:@"code"];

	if (_message != nil) {
		[dict setObject:_message forKey:@"message"];
	}
	return dict;
}
@end
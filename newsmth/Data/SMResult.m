#import "SMData.h"

@implementation SMResult
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_code = [[dict objectForKey:@"code"] intValue];

	id message = [dict objectForKey:@"message"];
	if (message != [NSNull null]) {
		_message = message;
	}

	_hasNotice = [[dict objectForKey:@"hasNotice"] boolValue];

	_notice = [[SMNotice alloc] initWithJSON:[dict objectForKey:@"notice"]];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_code) forKey:@"code"];

	if (_message != nil) {
		[dict setObject:_message forKey:@"message"];
	}

	[dict setObject:@(_hasNotice) forKey:@"hasNotice"];

	if (_notice != nil) {
		[dict setObject:[_notice encode] forKey:@"notice"];
	}
	return dict;
}
@end
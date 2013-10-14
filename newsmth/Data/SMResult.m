#import "SMData.h"

@implementation SMResult
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_code = [[dict objectForKey:@"code"] intValue];

	_message = [dict objectForKey:@"message"];

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
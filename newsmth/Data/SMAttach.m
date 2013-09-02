#import "SMData.h"

@implementation SMAttach
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_name = [dict objectForKey:@"name"];

	_len = [[dict objectForKey:@"len"] intValue];

	_pos = [[dict objectForKey:@"pos"] intValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_name != nil) {
		[dict setObject:_name forKey:@"name"];
	}

	[dict setObject:@(_len) forKey:@"len"];

	[dict setObject:@(_pos) forKey:@"pos"];
	return dict;
}
@end
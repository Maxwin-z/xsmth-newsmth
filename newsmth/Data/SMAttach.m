#import "SMData.h"

@implementation SMAttach
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id boardName = [dict objectForKey:@"boardName"];
	if (boardName != [NSNull null]) {
		_boardName = boardName;
	}

	_pid = [[dict objectForKey:@"pid"] intValue];

	id name = [dict objectForKey:@"name"];
	if (name != [NSNull null]) {
		_name = name;
	}

	_len = [[dict objectForKey:@"len"] intValue];

	_pos = [[dict objectForKey:@"pos"] intValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_boardName != nil) {
		[dict setObject:_boardName forKey:@"boardName"];
	}

	[dict setObject:@(_pid) forKey:@"pid"];

	if (_name != nil) {
		[dict setObject:_name forKey:@"name"];
	}

	[dict setObject:@(_len) forKey:@"len"];

	[dict setObject:@(_pos) forKey:@"pos"];
	return dict;
}
@end
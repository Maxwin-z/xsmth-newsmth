#import "SMData.h"

@implementation SMBoardListItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_isDir = [[dict objectForKey:@"isDir"] boolValue];

	id title = [dict objectForKey:@"title"];
	if (title != [NSNull null]) {
		_title = title;
	}

	id url = [dict objectForKey:@"url"];
	if (url != [NSNull null]) {
		_url = url;
	}

	_board = [[SMBoard alloc] initWithJSON:[dict objectForKey:@"board"]];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_isDir) forKey:@"isDir"];

	if (_title != nil) {
		[dict setObject:_title forKey:@"title"];
	}

	if (_url != nil) {
		[dict setObject:_url forKey:@"url"];
	}

	if (_board != nil) {
		[dict setObject:[_board encode] forKey:@"board"];
	}
	return dict;
}
@end
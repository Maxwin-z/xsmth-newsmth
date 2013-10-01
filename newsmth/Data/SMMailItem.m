#import "SMData.h"

@implementation SMMailItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_author = [dict objectForKey:@"author"];

	_title = [dict objectForKey:@"title"];

	_date = [[dict objectForKey:@"date"] longLongValue];

	_url = [dict objectForKey:@"url"];

	_content = [dict objectForKey:@"content"];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_author != nil) {
		[dict setObject:_author forKey:@"author"];
	}

	if (_title != nil) {
		[dict setObject:_title forKey:@"title"];
	}

	[dict setObject:@(_date) forKey:@"date"];

	if (_url != nil) {
		[dict setObject:_url forKey:@"url"];
	}

	if (_content != nil) {
		[dict setObject:_content forKey:@"content"];
	}
	return dict;
}
@end
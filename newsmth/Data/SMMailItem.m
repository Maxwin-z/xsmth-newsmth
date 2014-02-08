#import "SMData.h"

@implementation SMMailItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_unread = [[dict objectForKey:@"unread"] boolValue];

	id author = [dict objectForKey:@"author"];
	if (author != [NSNull null]) {
		_author = author;
	}

	id title = [dict objectForKey:@"title"];
	if (title != [NSNull null]) {
		_title = title;
	}

	_date = [[dict objectForKey:@"date"] longLongValue];

	id url = [dict objectForKey:@"url"];
	if (url != [NSNull null]) {
		_url = url;
	}

	id content = [dict objectForKey:@"content"];
	if (content != [NSNull null]) {
		_content = content;
	}

	id message = [dict objectForKey:@"message"];
	if (message != [NSNull null]) {
		_message = message;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_unread) forKey:@"unread"];

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

	if (_message != nil) {
		[dict setObject:_message forKey:@"message"];
	}
	return dict;
}
@end
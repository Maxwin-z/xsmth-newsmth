#import "SMData.h"

@implementation SMPost
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_pid = [[dict objectForKey:@"pid"] intValue];

	_gid = [[dict objectForKey:@"gid"] intValue];

	_board = [[SMBoard alloc] initWithJSON:[dict objectForKey:@"board"]];

	id author = [dict objectForKey:@"author"];
	if (author != [NSNull null]) {
		_author = author;
	}

	id nick = [dict objectForKey:@"nick"];
	if (nick != [NSNull null]) {
		_nick = nick;
	}

	id title = [dict objectForKey:@"title"];
	if (title != [NSNull null]) {
		_title = title;
	}

	id content = [dict objectForKey:@"content"];
	if (content != [NSNull null]) {
		_content = content;
	}

	_date = [[dict objectForKey:@"date"] longLongValue];

	id replyAuthor = [dict objectForKey:@"replyAuthor"];
	if (replyAuthor != [NSNull null]) {
		_replyAuthor = replyAuthor;
	}

	_replyDate = [[dict objectForKey:@"replyDate"] longLongValue];

	_replyCount = [[dict objectForKey:@"replyCount"] intValue];

	_isTop = [[dict objectForKey:@"isTop"] boolValue];

	_hasAttach = [[dict objectForKey:@"hasAttach"] boolValue];

	NSMutableArray *tmp_attaches = [[NSMutableArray alloc] init];
	NSArray *attaches = [dict objectForKey:@"attaches"];
	for (int i = 0; i != attaches.count; ++i) {
		[tmp_attaches addObject:[[SMAttach alloc] initWithJSON:attaches[i]]];
	}
	_attaches = tmp_attaches;

	_hasNotice = [[dict objectForKey:@"hasNotice"] boolValue];

	_notice = [[SMNotice alloc] initWithJSON:[dict objectForKey:@"notice"]];

	_readCount = [[dict objectForKey:@"readCount"] intValue];

	id links = [dict objectForKey:@"links"];
	if ([links isKindOfClass:[NSArray class]]) {
		_links = links;
	}

	id indexStr = [dict objectForKey:@"indexStr"];
	if (indexStr != [NSNull null]) {
		_indexStr = indexStr;
	}

	id dateStr = [dict objectForKey:@"dateStr"];
	if (dateStr != [NSNull null]) {
		_dateStr = dateStr;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_pid) forKey:@"pid"];

	[dict setObject:@(_gid) forKey:@"gid"];

	if (_board != nil) {
		[dict setObject:[_board encode] forKey:@"board"];
	}

	if (_author != nil) {
		[dict setObject:_author forKey:@"author"];
	}

	if (_nick != nil) {
		[dict setObject:_nick forKey:@"nick"];
	}

	if (_title != nil) {
		[dict setObject:_title forKey:@"title"];
	}

	if (_content != nil) {
		[dict setObject:_content forKey:@"content"];
	}

	[dict setObject:@(_date) forKey:@"date"];

	if (_replyAuthor != nil) {
		[dict setObject:_replyAuthor forKey:@"replyAuthor"];
	}

	[dict setObject:@(_replyDate) forKey:@"replyDate"];

	[dict setObject:@(_replyCount) forKey:@"replyCount"];

	[dict setObject:@(_isTop) forKey:@"isTop"];

	[dict setObject:@(_hasAttach) forKey:@"hasAttach"];

	NSMutableArray *tmp_attaches = [[NSMutableArray alloc] init];
	for (int i = 0; i != _attaches.count; ++i) {
		[tmp_attaches addObject:[_attaches[i] encode]];
	}
	[dict setObject:tmp_attaches forKey:@"attaches"];

	[dict setObject:@(_hasNotice) forKey:@"hasNotice"];

	if (_notice != nil) {
		[dict setObject:[_notice encode] forKey:@"notice"];
	}

	[dict setObject:@(_readCount) forKey:@"readCount"];

	if (_links != nil) {
		[dict setObject:_links forKey:@"links"];
	}

	if (_indexStr != nil) {
		[dict setObject:_indexStr forKey:@"indexStr"];
	}

	if (_dateStr != nil) {
		[dict setObject:_dateStr forKey:@"dateStr"];
	}
	return dict;
}
@end
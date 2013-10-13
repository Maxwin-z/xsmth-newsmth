#import "SMData.h"

@implementation SMPost
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_pid = [[dict objectForKey:@"pid"] intValue];

	_gid = [[dict objectForKey:@"gid"] intValue];

	_board = [[SMBoard alloc] initWithJSON:[dict objectForKey:@"board"]];

	_author = [dict objectForKey:@"author"];

	_nick = [dict objectForKey:@"nick"];

	_title = [dict objectForKey:@"title"];

	_content = [dict objectForKey:@"content"];

	_date = [[dict objectForKey:@"date"] longLongValue];

	_replyAuthor = [dict objectForKey:@"replyAuthor"];

	_replyDate = [[dict objectForKey:@"replyDate"] longLongValue];

	_replyCount = [[dict objectForKey:@"replyCount"] intValue];

	_isTop = [[dict objectForKey:@"isTop"] boolValue];

	NSMutableArray *tmp_attaches = [[NSMutableArray alloc] init];
	NSArray *attaches = [dict objectForKey:@"attaches"];
	for (int i = 0; i != attaches.count; ++i) {
		[tmp_attaches addObject:[[SMAttach alloc] initWithJSON:attaches[i]]];
	}
	_attaches = tmp_attaches;

	_hasNotice = [[dict objectForKey:@"hasNotice"] boolValue];

	_notice = [[SMNotice alloc] initWithJSON:[dict objectForKey:@"notice"]];
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

	NSMutableArray *tmp_attaches = [[NSMutableArray alloc] init];
	for (int i = 0; i != _attaches.count; ++i) {
		[tmp_attaches addObject:[_attaches[i] encode]];
	}
	[dict setObject:tmp_attaches forKey:@"attaches"];

	[dict setObject:@(_hasNotice) forKey:@"hasNotice"];

	if (_notice != nil) {
		[dict setObject:[_notice encode] forKey:@"notice"];
	}
	return dict;
}
@end
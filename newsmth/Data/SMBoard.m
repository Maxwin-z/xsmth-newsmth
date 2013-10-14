#import "SMData.h"

@implementation SMBoard
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_name = [dict objectForKey:@"name"];

	_cnName = [dict objectForKey:@"cnName"];

	_bid = [[dict objectForKey:@"bid"] intValue];

	NSMutableArray *tmp_posts = [[NSMutableArray alloc] init];
	NSArray *posts = [dict objectForKey:@"posts"];
	for (int i = 0; i != posts.count; ++i) {
		[tmp_posts addObject:[[SMPost alloc] initWithJSON:posts[i]]];
	}
	_posts = tmp_posts;

	_hasNotice = [[dict objectForKey:@"hasNotice"] boolValue];

	_notice = [[SMNotice alloc] initWithJSON:[dict objectForKey:@"notice"]];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_name != nil) {
		[dict setObject:_name forKey:@"name"];
	}

	if (_cnName != nil) {
		[dict setObject:_cnName forKey:@"cnName"];
	}

	[dict setObject:@(_bid) forKey:@"bid"];

	NSMutableArray *tmp_posts = [[NSMutableArray alloc] init];
	for (int i = 0; i != _posts.count; ++i) {
		[tmp_posts addObject:[_posts[i] encode]];
	}
	[dict setObject:tmp_posts forKey:@"posts"];

	[dict setObject:@(_hasNotice) forKey:@"hasNotice"];

	if (_notice != nil) {
		[dict setObject:[_notice encode] forKey:@"notice"];
	}
	return dict;
}
@end
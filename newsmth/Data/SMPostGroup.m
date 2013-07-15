#import "SMData.h"

@implementation SMPostGroup
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_bid = [[dict objectForKey:@"bid"] intValue];

	_tpage = [[dict objectForKey:@"tpage"] intValue];

	_title = [dict objectForKey:@"title"];

	NSMutableArray *tmp_posts = [[NSMutableArray alloc] init];
	NSArray *posts = [dict objectForKey:@"posts"];
	for (int i = 0; i != posts.count; ++i) {
		[tmp_posts addObject:[[SMPost alloc] initWithJSON:posts[i]]];
	}
	_posts = tmp_posts;
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_bid) forKey:@"bid"];

	[dict setObject:@(_tpage) forKey:@"tpage"];

	if (_title != nil) {
		[dict setObject:_title forKey:@"title"];
	}

	NSMutableArray *tmp_posts = [[NSMutableArray alloc] init];
	for (int i = 0; i != _posts.count; ++i) {
		[tmp_posts addObject:[_posts[i] encode]];
	}
	[dict setObject:tmp_posts forKey:@"posts"];
	return dict;
}
@end
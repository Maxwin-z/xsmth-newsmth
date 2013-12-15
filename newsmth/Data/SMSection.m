#import "SMData.h"

@implementation SMSection
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id sectionTitle = [dict objectForKey:@"sectionTitle"];
	if (sectionTitle != [NSNull null]) {
		_sectionTitle = sectionTitle;
	}

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
	if (_sectionTitle != nil) {
		[dict setObject:_sectionTitle forKey:@"sectionTitle"];
	}

	NSMutableArray *tmp_posts = [[NSMutableArray alloc] init];
	for (int i = 0; i != _posts.count; ++i) {
		[tmp_posts addObject:[_posts[i] encode]];
	}
	[dict setObject:tmp_posts forKey:@"posts"];
	return dict;
}
@end
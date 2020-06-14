#import "SMData.h"

@implementation SMUserTag
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	NSMutableArray *tmp_tags = [[NSMutableArray alloc] init];
	NSArray *tags = [dict objectForKey:@"tags"];
	for (int i = 0; i != tags.count; ++i) {
		[tmp_tags addObject:[[SMTag alloc] initWithJSON:tags[i]]];
	}
	_tags = tmp_tags;
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableArray *tmp_tags = [[NSMutableArray alloc] init];
	for (int i = 0; i != _tags.count; ++i) {
		[tmp_tags addObject:[_tags[i] encode]];
	}
	[dict setObject:tmp_tags forKey:@"tags"];
	return dict;
}
@end
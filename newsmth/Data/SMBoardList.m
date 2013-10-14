#import "SMData.h"

@implementation SMBoardList
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	NSMutableArray *tmp_items = [[NSMutableArray alloc] init];
	NSArray *items = [dict objectForKey:@"items"];
	for (int i = 0; i != items.count; ++i) {
		[tmp_items addObject:[[SMBoardListItem alloc] initWithJSON:items[i]]];
	}
	_items = tmp_items;

	_hasNotice = [[dict objectForKey:@"hasNotice"] boolValue];

	_notice = [[SMNotice alloc] initWithJSON:[dict objectForKey:@"notice"]];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableArray *tmp_items = [[NSMutableArray alloc] init];
	for (int i = 0; i != _items.count; ++i) {
		[tmp_items addObject:[_items[i] encode]];
	}
	[dict setObject:tmp_items forKey:@"items"];

	[dict setObject:@(_hasNotice) forKey:@"hasNotice"];

	if (_notice != nil) {
		[dict setObject:[_notice encode] forKey:@"notice"];
	}
	return dict;
}
@end
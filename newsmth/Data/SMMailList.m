#import "SMData.h"

@implementation SMMailList
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	NSMutableArray *tmp_items = [[NSMutableArray alloc] init];
	NSArray *items = [dict objectForKey:@"items"];
	for (int i = 0; i != items.count; ++i) {
		[tmp_items addObject:[[SMMailItem alloc] initWithJSON:items[i]]];
	}
	_items = tmp_items;

	_tpage = [[dict objectForKey:@"tpage"] intValue];

	_hasMail = [[dict objectForKey:@"hasMail"] boolValue];

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

	[dict setObject:@(_tpage) forKey:@"tpage"];

	[dict setObject:@(_hasMail) forKey:@"hasMail"];

	[dict setObject:@(_hasNotice) forKey:@"hasNotice"];

	if (_notice != nil) {
		[dict setObject:[_notice encode] forKey:@"notice"];
	}
	return dict;
}
@end
#import "SMData.h"

@implementation SMUpload
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_act = [[dict objectForKey:@"act"] intValue];

	_message = [dict objectForKey:@"message"];

	NSMutableArray *tmp_items = [[NSMutableArray alloc] init];
	NSArray *items = [dict objectForKey:@"items"];
	for (int i = 0; i != items.count; ++i) {
		[tmp_items addObject:[[SMUploadItem alloc] initWithJSON:items[i]]];
	}
	_items = tmp_items;

	_leftCount = [[dict objectForKey:@"leftCount"] intValue];

	_leftSize = [[dict objectForKey:@"leftSize"] intValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_act) forKey:@"act"];

	if (_message != nil) {
		[dict setObject:_message forKey:@"message"];
	}

	NSMutableArray *tmp_items = [[NSMutableArray alloc] init];
	for (int i = 0; i != _items.count; ++i) {
		[tmp_items addObject:[_items[i] encode]];
	}
	[dict setObject:tmp_items forKey:@"items"];

	[dict setObject:@(_leftCount) forKey:@"leftCount"];

	[dict setObject:@(_leftSize) forKey:@"leftSize"];
	return dict;
}
@end
#import "SMData.h"

@implementation SMFavor
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	NSMutableArray *tmp_boards = [[NSMutableArray alloc] init];
	NSArray *boards = [dict objectForKey:@"boards"];
	for (int i = 0; i != boards.count; ++i) {
		[tmp_boards addObject:[[SMBoard alloc] initWithJSON:boards[i]]];
	}
	_boards = tmp_boards;
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableArray *tmp_boards = [[NSMutableArray alloc] init];
	for (int i = 0; i != _boards.count; ++i) {
		[tmp_boards addObject:[_boards[i] encode]];
	}
	[dict setObject:tmp_boards forKey:@"boards"];
	return dict;
}
@end
#import "SMData.h"

@implementation SMMainPage
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	NSMutableArray *tmp_sections = [[NSMutableArray alloc] init];
	NSArray *sections = [dict objectForKey:@"sections"];
	for (int i = 0; i != sections.count; ++i) {
		[tmp_sections addObject:[[SMSection alloc] initWithJSON:sections[i]]];
	}
	_sections = tmp_sections;
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableArray *tmp_sections = [[NSMutableArray alloc] init];
	for (int i = 0; i != _sections.count; ++i) {
		[tmp_sections addObject:[_sections[i] encode]];
	}
	[dict setObject:tmp_sections forKey:@"sections"];
	return dict;
}
@end
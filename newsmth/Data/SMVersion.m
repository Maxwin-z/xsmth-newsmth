#import "SMData.h"

@implementation SMVersion
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_version = [[dict objectForKey:@"version"] intValue];

	_parser = [[dict objectForKey:@"parser"] intValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_version) forKey:@"version"];

	[dict setObject:@(_parser) forKey:@"parser"];
	return dict;
}
@end
#import "SMData.h"

@implementation SMVersion
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_version = [[dict objectForKey:@"version"] intValue];

	_parser = [[dict objectForKey:@"parser"] intValue];

	id adid = [dict objectForKey:@"adid"];
	if (adid != [NSNull null]) {
		_adid = adid;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_version) forKey:@"version"];

	[dict setObject:@(_parser) forKey:@"parser"];

	if (_adid != nil) {
		[dict setObject:_adid forKey:@"adid"];
	}
	return dict;
}
@end
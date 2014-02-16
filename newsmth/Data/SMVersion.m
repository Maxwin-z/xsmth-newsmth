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

	_gadradio = [[dict objectForKey:@"gadradio"] intValue];

	_iadradio = [[dict objectForKey:@"iadradio"] intValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_version) forKey:@"version"];

	[dict setObject:@(_parser) forKey:@"parser"];

	if (_adid != nil) {
		[dict setObject:_adid forKey:@"adid"];
	}

	[dict setObject:@(_gadradio) forKey:@"gadradio"];

	[dict setObject:@(_iadradio) forKey:@"iadradio"];
	return dict;
}
@end
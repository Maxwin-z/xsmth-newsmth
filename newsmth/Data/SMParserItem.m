#import "SMData.h"

@implementation SMParserItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_js = [dict objectForKey:@"js"];

	_path = [dict objectForKey:@"path"];

	_md5 = [dict objectForKey:@"md5"];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_js != nil) {
		[dict setObject:_js forKey:@"js"];
	}

	if (_path != nil) {
		[dict setObject:_path forKey:@"path"];
	}

	if (_md5 != nil) {
		[dict setObject:_md5 forKey:@"md5"];
	}
	return dict;
}
@end
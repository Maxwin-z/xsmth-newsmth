#import "SMData.h"

@implementation SMParserItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id js = [dict objectForKey:@"js"];
	if (js != [NSNull null]) {
		_js = js;
	}

	id path = [dict objectForKey:@"path"];
	if (path != [NSNull null]) {
		_path = path;
	}

	id md5 = [dict objectForKey:@"md5"];
	if (md5 != [NSNull null]) {
		_md5 = md5;
	}
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
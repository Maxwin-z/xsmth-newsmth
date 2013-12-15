#import "SMData.h"

@implementation SMUploadItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id name = [dict objectForKey:@"name"];
	if (name != [NSNull null]) {
		_name = name;
	}

	id key = [dict objectForKey:@"key"];
	if (key != [NSNull null]) {
		_key = key;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_name != nil) {
		[dict setObject:_name forKey:@"name"];
	}

	if (_key != nil) {
		[dict setObject:_key forKey:@"key"];
	}
	return dict;
}
@end
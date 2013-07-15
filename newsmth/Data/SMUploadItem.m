#import "SMData.h"

@implementation SMUploadItem
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_name = [dict objectForKey:@"name"];

	_key = [dict objectForKey:@"key"];
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
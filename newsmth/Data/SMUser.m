#import "SMData.h"

@implementation SMUser
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id info = [dict objectForKey:@"info"];
	if (info != [NSNull null]) {
		_info = info;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_info != nil) {
		[dict setObject:_info forKey:@"info"];
	}
	return dict;
}
@end
#import "SMData.h"

@implementation SMUser
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_info = [dict objectForKey:@"info"];
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
#import "SMData.h"

@implementation SMTag
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id tag = [dict objectForKey:@"tag"];
	if (tag != [NSNull null]) {
		_tag = tag;
	}

	id color = [dict objectForKey:@"color"];
	if (color != [NSNull null]) {
		_color = color;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_tag != nil) {
		[dict setObject:_tag forKey:@"tag"];
	}

	if (_color != nil) {
		[dict setObject:_color forKey:@"color"];
	}
	return dict;
}
@end
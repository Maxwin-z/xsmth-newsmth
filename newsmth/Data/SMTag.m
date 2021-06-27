#import "SMData.h"

@implementation SMTag
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	id text = [dict objectForKey:@"text"];
	if (text != [NSNull null]) {
		_text = text;
	}

	id color = [dict objectForKey:@"color"];
	if (color != [NSNull null]) {
		_color = color;
	}
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (_text != nil) {
		[dict setObject:_text forKey:@"text"];
	}

	if (_color != nil) {
		[dict setObject:_color forKey:@"color"];
	}
	return dict;
}
@end
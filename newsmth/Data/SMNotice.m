#import "SMData.h"

@implementation SMNotice
- (void)decode:(id)json
{
	NSDictionary *dict = json;
	_at = [[dict objectForKey:@"at"] intValue];

	_reply = [[dict objectForKey:@"reply"] intValue];

	_mail = [[dict objectForKey:@"mail"] intValue];
}

- (id)encode
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:@(_at) forKey:@"at"];

	[dict setObject:@(_reply) forKey:@"reply"];

	[dict setObject:@(_mail) forKey:@"mail"];
	return dict;
}
@end
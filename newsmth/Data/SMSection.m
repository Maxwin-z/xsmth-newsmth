#import "SMSection.h"

@implementation SMSection
- (NSString *)sectionTitle
{
	return [self.dict objectForKey:@"sectionTitle"];
}

- (NSArray *)posts
{
	NSArray *objs = [self.dict objectForKey:@"posts"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
}

@end
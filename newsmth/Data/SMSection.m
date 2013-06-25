#import "SMSection.h"

@implementation SMSection
- (NSString *)sectionTitle
{
	return [self.dict objectForKey:@"sectionTitle"];
}

- (void)setSectionTitle:(NSString *)sectionTitle_
{
	[self.dict setObject:sectionTitle_ forKey:@"sectionTitle"];
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

- (void)setPosts:(NSArray *)posts_
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:posts_.count];
    for (int i = 0; i != posts_.count; ++i) {
        [arr addObject:[posts_[i] dict]];
    }
    [self.dict setObject:arr forKey:@"posts"];
}

@end
#import "SMPost.h"

@implementation SMPost
- (int)pid
{
	return [[self.dict objectForKey:@"pid"] intValue];
}

- (int)gid
{
	return [[self.dict objectForKey:@"gid"] intValue];
}

- (NSString *)board
{
	return [self.dict objectForKey:@"board"];
}

- (NSString *)boardName
{
	return [self.dict objectForKey:@"boardName"];
}

- (NSString *)author
{
	return [self.dict objectForKey:@"author"];
}

- (NSString *)nick
{
	return [self.dict objectForKey:@"nick"];
}

- (NSString *)title
{
	return [self.dict objectForKey:@"title"];
}

- (NSString *)content
{
	return [self.dict objectForKey:@"content"];
}

- (long)date
{
	return [[self.dict objectForKey:@"date"] longValue];
}

- (NSArray *)attaches
{
	NSArray *objs = [self.dict objectForKey:@"attaches"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
}

@end
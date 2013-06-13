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

- (long long)date
{
	return [[self.dict objectForKey:@"date"] longLongValue];
}

- (NSString *)replyAuthor
{
	return [self.dict objectForKey:@"replyAuthor"];
}

- (long long)replyDate
{
	return [[self.dict objectForKey:@"replyDate"] longLongValue];
}

- (int)replyCount
{
	return [[self.dict objectForKey:@"replyCount"] intValue];
}

- (NSArray *)isTop;
{
	NSArray *objs = [self.dict objectForKey:@"isTop;"];
	NSMutableArray *res = [[NSMutableArray alloc] init];
	for (int i = 0; i != objs.count; ++i) {
		SMBaseData *data = [[SMBaseData alloc] initWithData:objs[i]];
		[res addObject:data];
	}
	return res;
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
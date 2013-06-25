#import "SMPost.h"

@implementation SMPost
- (int)pid
{
	return [[self.dict objectForKey:@"pid"] intValue];
}

- (void)setPid:(int)pid_
{
	[self.dict setInteger:pid_ forKey:@"pid"];
}

- (int)gid
{
	return [[self.dict objectForKey:@"gid"] intValue];
}

- (void)setGid:(int)gid_
{
	[self.dict setInteger:gid_ forKey:@"gid"];
}

- (NSString *)board
{
	return [self.dict objectForKey:@"board"];
}

- (void)setBoard:(NSString *)board_
{
	[self.dict setObject:board_ forKey:@"board"];
}

- (NSString *)boardName
{
	return [self.dict objectForKey:@"boardName"];
}

- (void)setBoardName:(NSString *)boardName_
{
	[self.dict setObject:boardName_ forKey:@"boardName"];
}

- (NSString *)author
{
	return [self.dict objectForKey:@"author"];
}

- (void)setAuthor:(NSString *)author_
{
	[self.dict setObject:author_ forKey:@"author"];
}

- (NSString *)nick
{
	return [self.dict objectForKey:@"nick"];
}

- (void)setNick:(NSString *)nick_
{
	[self.dict setObject:nick_ forKey:@"nick"];
}

- (NSString *)title
{
	return [self.dict objectForKey:@"title"];
}

- (void)setTitle:(NSString *)title_
{
	[self.dict setObject:title_ forKey:@"title"];
}

- (NSString *)content
{
	return [self.dict objectForKey:@"content"];
}

- (void)setContent:(NSString *)content_
{
	[self.dict setObject:content_ forKey:@"content"];
}

- (long long)date
{
	return [[self.dict objectForKey:@"date"] longLongValue];
}

- (void)setDate:(long long)date_
{
	[self.dict setLongLong:date_ forKey:@"date"];
}

- (NSString *)replyAuthor
{
	return [self.dict objectForKey:@"replyAuthor"];
}

- (void)setReplyAuthor:(NSString *)replyAuthor_
{
	[self.dict setObject:replyAuthor_ forKey:@"replyAuthor"];
}

- (long long)replyDate
{
	return [[self.dict objectForKey:@"replyDate"] longLongValue];
}

- (void)setReplyDate:(long long)replyDate_
{
	[self.dict setLongLong:replyDate_ forKey:@"replyDate"];
}

- (int)replyCount
{
	return [[self.dict objectForKey:@"replyCount"] intValue];
}

- (void)setReplyCount:(int)replyCount_
{
	[self.dict setInteger:replyCount_ forKey:@"replyCount"];
}

- (BOOL)isTop
{
	return [[self.dict objectForKey:@"isTop"] boolValue];
}

- (void)setIsTop:(BOOL)isTop_
{
	[self.dict setBool:isTop_ forKey:@"isTop"];
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

- (void)setAttaches:(NSArray *)attaches_
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:attaches_.count];
    for (int i = 0; i != attaches_.count; ++i) {
        [arr addObject:[attaches_[i] dict]];
    }
    [self.dict setObject:arr forKey:@"attaches"];
}

@end
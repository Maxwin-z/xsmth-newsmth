#import "SMData.h"

@implementation SMBoardListItem
- (BOOL)isDir
{
	return [[self.dict objectForKey:@"isDir"] boolValue];
}

- (void)setIsDir:(BOOL)isDir_
{
	[self.dict setValue:@(isDir_) forKey:@"isDir"];
}

- (NSString *)title
{
	return [self.dict objectForKey:@"title"];
}

- (void)setTitle:(NSString *)title_
{
	[self.dict setObject:title_ forKey:@"title"];
}

- (NSString *)url
{
	return [self.dict objectForKey:@"url"];
}

- (void)setUrl:(NSString *)url_
{
	[self.dict setObject:url_ forKey:@"url"];
}

- (SMBoard *)board
{
	SMBoard *data = [[SMBoard alloc] initWithData:[self.dict objectForKey:@"board"]];
	return data;
}

- (void)setBoard:(SMBaseData *)board_
{
	[self.dict setObject:board_.dict forKey:@"board"];
}

@end
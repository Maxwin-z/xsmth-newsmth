#import "SMBaseData.h"

@interface SMPost : SMBaseData
@property (assign, nonatomic) int pid;
@property (assign, nonatomic) int gid;
@property (strong, nonatomic) NSString* board;
@property (strong, nonatomic) NSString* boardName;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* nick;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* content;
@property (assign, nonatomic) long long date;
@property (strong, nonatomic) NSString* replyAuthor;
@property (assign, nonatomic) long long replyDate;
@property (assign, nonatomic) int replyCount;
@property (strong, nonatomic) NSArray* isTop;;
@property (strong, nonatomic) NSArray* attaches;
@end
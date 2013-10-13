#import "SMBaseData.h"

@class SMBoard;
@class SMAttach;
@class SMNotice;
@interface SMPost : SMBaseData
@property (assign, nonatomic) int pid;
@property (assign, nonatomic) int gid;
@property (strong, nonatomic) SMBoard* board;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* nick;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* content;
@property (assign, nonatomic) long long date;
@property (strong, nonatomic) NSString* replyAuthor;
@property (assign, nonatomic) long long replyDate;
@property (assign, nonatomic) int replyCount;
@property (assign, nonatomic) BOOL isTop;
@property (strong, nonatomic) NSArray* attaches;
@property (assign, nonatomic) BOOL hasNotice;
@property (strong, nonatomic) SMNotice* notice;
@end
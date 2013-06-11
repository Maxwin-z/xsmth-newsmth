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
@property (strong, nonatomic) NSArray* attaches;
@end
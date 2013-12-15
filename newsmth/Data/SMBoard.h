#import "SMBaseData.h"

@class SMPost;
@class SMNotice;
@interface SMBoard : SMBaseData
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* cnName;
@property (assign, nonatomic) int bid;
@property (strong, nonatomic) NSArray* posts;
@property (assign, nonatomic) BOOL hasNotice;
@property (strong, nonatomic) SMNotice* notice;
@property (assign, nonatomic) int currentPage;
@end
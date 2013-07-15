#import "SMBaseData.h"

@class SMBoard;
@interface SMBoardListItem : SMBaseData
@property (assign, nonatomic) bool isDir;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) SMBoard* board;
@end
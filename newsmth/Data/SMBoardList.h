#import "SMBaseData.h"

@class SMBoardListItem;
@class SMNotice;
@interface SMBoardList : SMBaseData
@property (strong, nonatomic) NSArray* items;
@property (assign, nonatomic) BOOL hasNotice;
@property (strong, nonatomic) SMNotice* notice;
@end
#import "SMBaseData.h"

@class SMMailItem;
@class SMNotice;
@interface SMMailList : SMBaseData
@property (strong, nonatomic) NSArray* items;
@property (assign, nonatomic) int tpage;
@property (assign, nonatomic) BOOL hasMail;
@property (assign, nonatomic) BOOL hasNotice;
@property (strong, nonatomic) SMNotice* notice;
@end
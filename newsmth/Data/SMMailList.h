#import "SMBaseData.h"

@class SMMailItem;
@interface SMMailList : SMBaseData
@property (strong, nonatomic) NSArray* items;
@property (assign, nonatomic) int tpage;
@property (assign, nonatomic) BOOL hasMail;
@end
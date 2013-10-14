#import "SMBaseData.h"

@class SMNotice;
@interface SMResult : SMBaseData
@property (assign, nonatomic) int code;
@property (strong, nonatomic) NSString* message;
@property (assign, nonatomic) BOOL hasNotice;
@property (strong, nonatomic) SMNotice* notice;
@end
#import "SMBaseData.h"


@interface SMResult : SMBaseData
@property (assign, nonatomic) int code;
@property (strong, nonatomic) NSString* message;
@end
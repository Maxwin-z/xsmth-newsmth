#import "SMBaseData.h"


@interface SMWriteResult : SMBaseData
@property (assign, nonatomic) BOOL success;
@property (strong, nonatomic) NSString* message;
@end
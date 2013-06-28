#import "SMBaseData.h"


@interface SMBoard : SMBaseData
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* cnName;
@property (assign, nonatomic) int bid;
@property (strong, nonatomic) NSArray* posts;
@end
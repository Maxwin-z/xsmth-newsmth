#import "SMBaseData.h"

@interface SMPostGroup : SMBaseData
@property (assign, nonatomic) int bid;
@property (assign, nonatomic) int tpage;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSArray* posts;
@end
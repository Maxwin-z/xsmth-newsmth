#import "SMBaseData.h"

@class SMPost;
@interface SMSection : SMBaseData
@property (strong, nonatomic) NSString* sectionTitle;
@property (strong, nonatomic) NSArray* posts;
@end
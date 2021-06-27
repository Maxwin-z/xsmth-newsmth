#import "SMBaseData.h"

@class SMTag;
@interface SMUserTag : SMBaseData
@property (strong, nonatomic) NSString* user;
@property (strong, nonatomic) NSArray* tags;
@end
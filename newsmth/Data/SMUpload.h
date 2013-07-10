#import "SMBaseData.h"


@interface SMUpload : SMBaseData
@property (assign, nonatomic) int act;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSArray* items;
@property (assign, nonatomic) int leftCount;
@property (assign, nonatomic) int leftSize;
@end
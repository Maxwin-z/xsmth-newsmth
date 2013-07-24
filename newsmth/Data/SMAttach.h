#import "SMBaseData.h"


@interface SMAttach : SMBaseData
@property (strong, nonatomic) NSString* boardName;
@property (assign, nonatomic) int pid;
@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) int len;
@property (assign, nonatomic) int pos;
@end
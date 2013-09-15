#import "SMBaseData.h"


@interface SMMailItem : SMBaseData
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) long long date;
@property (strong, nonatomic) NSString* url;
@end
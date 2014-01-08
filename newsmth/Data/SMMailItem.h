#import "SMBaseData.h"


@interface SMMailItem : SMBaseData
@property (assign, nonatomic) BOOL unread;
@property (strong, nonatomic) NSString* author;
@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) long long date;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* content;
@property (strong, nonatomic) NSString* message;
@end
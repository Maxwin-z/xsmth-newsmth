#import "SMBaseData.h"


@interface SMVersion : SMBaseData
@property (assign, nonatomic) int version;
@property (assign, nonatomic) int parser;
@property (strong, nonatomic) NSString* adid;
@property (assign, nonatomic) int gadradio;
@property (assign, nonatomic) int iadradio;
@end
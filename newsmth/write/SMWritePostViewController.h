//
//  SMWritePostViewController.h
//  newsmth
//
//  Created by Maxwin on 13-6-23.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMViewController.h"
#import "SMPost.h"

@interface SMWritePostViewController : SMViewController
@property (strong, nonatomic) SMPost *post;
@property (strong, nonatomic) NSString *postTitle;
@property (strong, nonatomic) SMPost *editPost;
@end

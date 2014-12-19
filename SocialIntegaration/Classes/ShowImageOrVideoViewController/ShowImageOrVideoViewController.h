//
//  ShowImageOrVideoViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "UIImageView+WebCache.h"

@interface ShowImageOrVideoViewController : UIViewController

@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) IBOutlet UIImageView *imgVwLargeImg;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollVwImg;
@property (nonatomic, strong) IBOutlet UIWebView *webViewVideo;
@property (nonatomic, strong) UIImage *imgLarge;

@end

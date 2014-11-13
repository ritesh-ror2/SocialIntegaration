//
//  AppDelegate.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) FBSession *fbSession;
@property (nonatomic) BOOL hasFacebook;
@property (nonatomic, strong) MBProgressHUD *spinner;
@property (nonatomic, strong) Instagram *instagram;
@property (nonatomic, strong) NSString *InstagramId;

@end

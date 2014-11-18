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
#import <Accounts/Accounts.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) FBSession *fbSession;
@property (nonatomic) BOOL hasFacebook;
@property (nonatomic, strong) MBProgressHUD *spinner;
@property (nonatomic, strong) Instagram *instagram;
@property (nonatomic, strong) NSString *InstagramId;
@property (nonatomic, strong) ACAccount *twitterAccount;

@property (strong, nonatomic) NSMutableArray *arryOfFBNewsFeed;
@property (strong, nonatomic) NSMutableArray *arryOfInstagrame;
@property (strong, nonatomic) NSMutableArray *arryOfTwittes;
@property (strong, nonatomic) NSMutableArray *arryOfAllFeeds;


@end

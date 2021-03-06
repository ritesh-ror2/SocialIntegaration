//
//  SettingsViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constant.h"
#import "Reachability.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import <Social/Social.h>

@interface SettingsViewController () <IGRequestDelegate, IGSessionDelegate>

@end

@implementation SettingsViewController

#pragma mark - View life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    NSString *strFbImage;
    NSString *strTwitterImg;
    NSString *strinst;
    if (IS_IPHONE5) {
        strFbImage = @"facebook-bg1.png";
        strTwitterImg = @"twitter-bg1.png";
        strinst = @"instagram-bg1.png";
    } else {
        strFbImage = @"facebook-bg.png";
        strTwitterImg = @"twitter-bg.png";
        strinst = @"instagram-bg.png";
    }
    vwFB.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:strFbImage]]; //[UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    vwTwitter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:strTwitterImg]];//[UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
    vwInstagram.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:strinst]];//[UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    btnFb.hidden = YES;
    btnInstagram.hidden = YES;
    btnTwitter.hidden = YES;
    sharedAppDelegate.isFirstTimeLaunch = NO;
    btnInstagram.frame = CGRectMake(0, vwInstagram.frame.origin.y, btnInstagram.frame.size.width, vwInstagram.frame.size.height);


    [self userLoginOrNot];

    if (IS_IPHONE_6_IOS8 || IS_IPHONE_6P_IOS8) {
        [self setFrameOfViewsForiPhone6And6plus];
    } else {

        vwTwitter.frame = CGRectMake (0, vwTwitter.frame.origin.y, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
    }
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [Constant hideNetworkIndicator];
        return;
    }
}

- (void)setFrameOfViewsForiPhone6And6plus {

    int yAxis;
    int increaseHeight;
    int yAxisTwitter;
    if (IS_IPHONE_6_IOS8) {
        yAxis = 210;
        increaseHeight = 10;
        yAxisTwitter = 2;
    } else {
        yAxis = 235;
        increaseHeight = 15;
        yAxisTwitter = 0;
    }

    imgVwTwitterCircle.image = [UIImage imageNamed:@"mask-border.png"];
    imgVwFBCircle.image = [UIImage imageNamed:@"mask-border.png"];
    imgVwInstagramCircle.image = [UIImage imageNamed:@"mask-border.png"];

    btnTwitter.frame = CGRectMake(-60, yAxis-3, btnTwitter.frame.size.width, vwTwitter.frame.size.height);

    vwTwitter.frame = CGRectMake (0, yAxis, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
    //twitter
    imgVwTwitter.frame = CGRectMake((self.view.frame.size.width - 98)/2, imgVwTwitter.frame.origin.y+yAxisTwitter, 98, 98);
    imgVwTwitterCircle.frame = CGRectMake((self.view.frame.size.width - 100)/2, imgVwTwitterCircle.frame.origin.y+yAxisTwitter, 100, 100);
    btnTwitterAdd.frame = CGRectMake((self.view.frame.size.width - 64)/2, btnTwitterAdd.frame.origin.y+20, 64, 64);
    lblTwitterName.frame = CGRectMake(lblFBName.frame.origin.x, imgVwTwitter.frame.origin.y + imgVwTwitter.frame.size.height + 5, lblTwitterName.frame.size.width, lblTwitterName.frame.size.height);
     lblTwitterTitle.frame = CGRectMake(lblTwitterTitle.frame.origin.x, lblTwitterName.frame.origin.y + lblTwitterName.frame.size.height + 5, lblTwitterTitle.frame.size.width, lblTwitterTitle.frame.size.height);

    //facebook
    vwFB.frame = CGRectMake (0, vwFB.frame.origin.y, vwFB.frame.size.width, vwFB.frame.size.height+increaseHeight);
    //  btnFb.frame = CGRectMake(0, yAxis, btnFb.frame.size.width, vwFB.frame.size.height);
    imgVwFB.frame = CGRectMake((self.view.frame.size.width - 98)/2, imgVwFB.frame.origin.y, 98, 98);
    imgVwFBCircle.frame = CGRectMake((self.view.frame.size.width - 100)/2, imgVwFBCircle.frame.origin.y, 100, 100);
    btnFbAdd.frame = CGRectMake((self.view.frame.size.width - 64)/2, btnFbAdd.frame.origin.y+20, 64, 64);
    lblFBName.frame = CGRectMake(lblFBName.frame.origin.x, imgVwFB.frame.origin.y + imgVwFB.frame.size.height + 5, lblFBName.frame.size.width,lblFBName.frame.size.height);
    lblFBTitle.frame = CGRectMake(lblFBTitle.frame.origin.x, lblFBName.frame.origin.y + lblFBName.frame.size.height + 5, lblFBTitle.frame.size.width, lblFBTitle.frame.size.height);

    //instagram
    imgVwInstagram.frame = CGRectMake((self.view.frame.size.width - 98)/2, imgVwInstagram.frame.origin.y+5, 98, 98);
    imgVwInstagramCircle.frame = CGRectMake((self.view.frame.size.width - 100)/2, imgVwInstagramCircle.frame.origin.y+5, 100, 100);
    btnInstagramAdd.frame = CGRectMake((self.view.frame.size.width - 64)/2, btnInstagramAdd.frame.origin.y+30, 64, 64);
    lblInstagramName.frame = CGRectMake(lblInstagramName.frame.origin.x, imgVwInstagram.frame.origin.y + imgVwInstagram.frame.size.height + 5, lblInstagramName.frame.size.width, lblInstagramName.frame.size.height);
    lblInstagramTitle.frame = CGRectMake(lblInstagramTitle.frame.origin.x, lblInstagramName.frame.origin.y + lblInstagramName.frame.size.height + 5, lblInstagramTitle.frame.size.width, lblInstagramTitle.frame.size.height);
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    self.navigationController.navigationBarHidden = YES;
    btnFb.hidden = NO;
    btnInstagram.hidden = NO;
    btnTwitter.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    btnFb.hidden = YES;
    btnInstagram.hidden = YES;
    btnTwitter.hidden = YES;
}

#pragma mark - User Login or not

- (void)userLoginOrNot {

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];

    if (isFbUserLogin == YES) {

        if (![SLComposeViewController
              isAvailableForServiceType:SLServiceTypeFacebook]) {

                // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER_SETTING];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISFBLOGIN];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [UserProfile deleteProfile:@"Facebook"];
            [Constant hideNetworkIndicator];
            return;
        }
        UserProfile *userProfile = [UserProfile getProfile:@"Facebook"];
        [self setFBUserInfo:userProfile];
    } else {

        [self hideFBBtn:NO];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISFBLOGIN];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    //twitter login
    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];

    if (isTwitterUserLogin == YES) {

        if (![SLComposeViewController
              isAvailableForServiceType:SLServiceTypeTwitter]) {

            [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER_SETTING];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISTWITTERLOGIN];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [UserProfile deleteProfile:@"Twitter"];

            [Constant hideNetworkIndicator];

            return;
        }
        [self hideTwitterBtn:YES];
        UserProfile *userProfile = [UserProfile getProfile:@"Twitter"];
        [self setTwitterUserInfo:userProfile];
    } else {

        [self hideTwitterBtn:NO];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISTWITTERLOGIN];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    //instagram
    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];

    if (isInstagramUserLogin == YES) {

        [self hideInstagramBtn:YES];
        UserProfile *userProfile = [UserProfile getProfile:@"Instagram"];
        [self setInstagramUserInfo:userProfile];
    } else {

        [self hideInstagramBtn:NO];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISINSTAGRAMLOGIN];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

#pragma mark - Hide Twitter btn
/**************************************************************************************************
 Function to hide twitter btn
 **************************************************************************************************/

- (void)hideTwitterBtn:(BOOL)isLogin {

     if (isLogin == YES) {

         [btnTwitterAdd setHidden:YES];
         [imgVwTwitter setHidden:NO];
         [imgVwTwitterCircle setHidden:NO];
         lblTwitterName.hidden = NO;
     } else {

         [btnTwitterAdd setHidden:NO];
         [imgVwTwitter setHidden:YES];
         [imgVwTwitterCircle setHidden:YES];
         lblTwitterName.hidden = YES;
     }
}

#pragma mark - Hide facebook btn
/**************************************************************************************************
 Function to hide facebook btn
 **************************************************************************************************/

- (void)hideFBBtn:(BOOL)isLogin {

    if (isLogin == YES) {

        [btnFbAdd setHidden:YES];
        [imgVwFB setHidden:NO];
        [imgVwFBCircle setHidden:NO];
        lblFBName.hidden = NO;
    } else {

        [btnFbAdd setHidden:NO];
        [imgVwFB setHidden:YES];
        [imgVwFBCircle setHidden:YES];
        lblFBName.hidden = YES;
    }
}

#pragma mark - Hide instagram btn
/**************************************************************************************************
 Function to hide instagram btn
 **************************************************************************************************/

- (void)hideInstagramBtn:(BOOL)isLogin {

    if (isLogin == YES) {

        [btnInstagramAdd setHidden:YES];
        [imgVwInstagram setHidden:NO];
        [imgVwInstagramCircle setHidden:NO];
        lblInstagramName.hidden = NO;
    } else {

        [btnInstagramAdd setHidden:NO];
        [imgVwInstagram setHidden:YES];
        [imgVwInstagramCircle setHidden:YES];
        lblInstagramName.hidden = YES;
    }
}

#pragma mark - Add Gesture on fb view
/**************************************************************************************************
 Function to add gesture on fb view
 **************************************************************************************************/

- (void)addGestureOnFbView {

    UISwipeGestureRecognizer * swiperight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandle:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    [vwFB addGestureRecognizer:swiperight];

    UISwipeGestureRecognizer * swipeleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandle:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [vwFB addGestureRecognizer:swipeleft];
}

#pragma mark - Add Gesture on twitter view
/**************************************************************************************************
 Function to add gesture on twitter view
 **************************************************************************************************/

- (void)addGestureOnTwitterView {

    UISwipeGestureRecognizer * swiperightTweet = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandleOfTwitter:)];
    swiperightTweet.direction = UISwipeGestureRecognizerDirectionRight;
    [vwTwitter addGestureRecognizer:swiperightTweet];

    UISwipeGestureRecognizer * swipeleftTweet = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandleOfTwitter:)];
    swipeleftTweet.direction = UISwipeGestureRecognizerDirectionLeft;
    [vwTwitter addGestureRecognizer:swipeleftTweet];
}

#pragma mark - Facebook btn tapped
/**************************************************************************************************
 Function to facebook btn tapped
 **************************************************************************************************/

- (IBAction)facebookBtnTapped:(id)sender {

   /* [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];*/

    [Constant showNetworkIndicator];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [Constant hideNetworkIndicator];

        return;
    }

    if (![SLComposeViewController
          isAvailableForServiceType:SLServiceTypeFacebook]) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB_SETTING];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISFBLOGIN];
        [Constant hideNetworkIndicator];

        return;
    } else {

        if (FBSession.activeSession.state == FBSessionStateOpen ||
            FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {

            sharedAppDelegate.fbSession = FBSession.activeSession;
            sharedAppDelegate.hasFacebook = YES;
        }
    }
    [self getProfileOfFB];
}

#pragma mark - Login with facebook
/**************************************************************************************************
 Function to login on facebook
 **************************************************************************************************/

- (void)loginFacebook {

    [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info",  @"read_stream"]  allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
	                                                  FBSessionState state,
	                                                  NSError *error) {
                                      if (error) {

                                          sharedAppDelegate.hasFacebook = NO;
                                          [Constant hideNetworkIndicator];
                                      } else {

                                          sharedAppDelegate.fbSession = session;
                                          sharedAppDelegate.hasFacebook = YES;

                                          [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISFBLOGIN];
                                          [[NSUserDefaults standardUserDefaults]synchronize];

                                          [self getProfileOfFB];
                                      }
		                          }];
}

#pragma mark - Get user facebook profile info
/**************************************************************************************************
 Function to get user facebook profile info
 **************************************************************************************************/

- (void)getProfileOfFB {

    if (!sharedAppDelegate.hasFacebook) {
		[self loginFacebook];
		return;
	}

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"access_token"] = sharedAppDelegate.fbSession.accessTokenData;

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"publish_stream", @"publish_actions"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {

        FBRequest *request = [FBRequest requestForGraphPath:@"me"];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (error) {

                    //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
                [Constant hideNetworkIndicator];
            } else {

                NSDictionary *dictInfo = (NSDictionary *)result;
                [self getProfileImg:dictInfo];
            }
        }];
    }];
}

#pragma mark - Get profile image
/**************************************************************************************************
 Function to get  profile image
 **************************************************************************************************/

- (void)getProfileImg:(NSDictionary *)userInfo {

    FBRequest *request = [FBRequest requestForGraphPath:@"me?fields=picture"];

	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (error) {
                // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
		} else {

            NSDictionary *dictInfo = (NSDictionary *)result;
            NSString *strProfileImg = [[[dictInfo objectForKey:@"picture"] objectForKey:@"data"]objectForKey:@"url"];
            [self convertFBUserInfoInModel:userInfo withProfileImg:strProfileImg];
		}
	}];
}

#pragma mark - Convert profile into model class object
/**************************************************************************************************
 Function to convert profile into model class object
 **************************************************************************************************/

- (void)convertFBUserInfoInModel:(NSDictionary *)dictInfo withProfileImg:(NSString *)strProfileImg {

    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISFBLOGIN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    UserProfile *userProfile = [[UserProfile alloc]init];
    userProfile.userName = [dictInfo objectForKey:@"name"];
    userProfile.userImg = strProfileImg;
    userProfile.userId = [dictInfo objectForKey:@"id"];
    userProfile.type = @"Facebook";

    [self setFBUserInfo:userProfile];
    [userProfile saveUserProfile];
}

#pragma mark - Show user profile info
/**************************************************************************************************
 Function to convert profile into model class object
 **************************************************************************************************/

- (void)setFBUserInfo:(UserProfile*)userProfile {

    [self addGestureOnFbView];
        // [self setGradientColorOfFB];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    [self hideFBBtn:isFbUserLogin];

    [Constant hideNetworkIndicator];

    lblFBName.text = userProfile.userName;

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask_Link.png"]];
            imgVwFB.image = imgProfile;
        });
    });
}

#pragma mark - Swipe on view
/**************************************************************************************************
 Function to handle swipe on view
 **************************************************************************************************/

- (void)swipeHandle:(UISwipeGestureRecognizer *)swipeRecognizer {

    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {

        [UIView animateWithDuration:0.5 animations:^ {

            vwFB.frame = CGRectMake(60, vwFB.frame.origin.y, vwFB.frame.size.width, vwFB.frame.size.height);
            btnFb.frame =  CGRectMake(0, vwFB.frame.origin.y, 60, vwFB.frame.size.height);
        }];
    } else {
        vwFB.frame = CGRectMake(0, vwFB.frame.origin.y, vwFB.frame.size.width, vwFB.frame.size.height);
        btnFb.frame =  CGRectMake(-60, vwFB.frame.origin.y, 60, vwFB.frame.size.height);
    }
}

#pragma mark - Twitter btn tapped
/**************************************************************************************************
 Function to twitter btn tapped
 **************************************************************************************************/

- (IBAction)twitterBtnTapped:(id)sender {

    [Constant showNetworkIndicator];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [Constant hideNetworkIndicator];
        return;
    }

    if (![SLComposeViewController
          isAvailableForServiceType:SLServiceTypeTwitter]) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER_SETTING];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISTWITTERLOGIN];
        [Constant hideNetworkIndicator];
        return;
    } else {

        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account
                                      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error)
         {
           if (granted == YES) {
               NSArray *arrayOfAccounts = [account
                                           accountsWithAccountType:accountType];

               if ([arrayOfAccounts count] > 0)
                 {
                   sharedAppDelegate.twitterAccount = [arrayOfAccounts lastObject];

                   NSURL *requestURL = [NSURL URLWithString:TWITTER_USER_PROFILE];
                   SLRequest *timelineRequest = [SLRequest
                                                 requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:SLRequestMethodGET
                                                 URL:requestURL parameters:nil];

                   timelineRequest.account = sharedAppDelegate.twitterAccount;

                   [timelineRequest performRequestWithHandler:
                    ^(NSData *responseData, NSHTTPURLResponse
                      *urlResponse, NSError *error) {

                        if (error) {

                                //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_AUTHEN];
                            return ;
                        } else {

                            NSArray *arryTwitte = [NSJSONSerialization
                                                   JSONObjectWithData:responseData
                                                   options:NSJSONReadingMutableLeaves
                                                   error:&error];

                            if (arryTwitte.count != 0) {
                                dispatch_async(dispatch_get_main_queue(), ^{

                                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISTWITTERLOGIN];
                                    [[NSUserDefaults standardUserDefaults]synchronize];

                                    NSDictionary *dictInfo = (NSDictionary *)arryTwitte;
                                    [self convertTwitterProfileInfo:dictInfo];
                                });
                            }
                        }
                    }];
                 }
           } else {
               
                   // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_AUTHEN];
           }
         }];
    }
}

#pragma mark - Twitter btn tapped
/**************************************************************************************************
 Function to twitter btn tapped
 **************************************************************************************************/

- (void)convertTwitterProfileInfo:(NSDictionary *)dictData {

    UserProfile *userProfile = [[UserProfile alloc]init];
    userProfile.userName = [dictData valueForKey:@"screen_name"];
    userProfile.userImg = [dictData valueForKey:@"profile_image_url"];
    userProfile.following = [NSString stringWithFormat:@"%li", (long)[[dictData valueForKey:@"friends_count"] integerValue]];
    userProfile.tweet = [NSString stringWithFormat:@"%li",(long)[[dictData valueForKey:@"statuses_count"] integerValue]];
    userProfile.followers = [NSString stringWithFormat:@"%li",(long)[[dictData valueForKey:@"followers_count"]integerValue]];
    userProfile.type = @"Twitter";
    userProfile.userId  =  [NSString stringWithFormat:@"%lf",[[[dictData valueForKey:@"status"]valueForKey:@"id"] doubleValue]];
    userProfile.description = [dictData objectForKey:@"description"];
    
    [self setTwitterUserInfo:userProfile];
    [userProfile saveUserProfile];
}

#pragma mark - Set twitter user info
/**************************************************************************************************
 Function to set twitter user info
 **************************************************************************************************/

- (void)setTwitterUserInfo:(UserProfile*)userProfile {

    [self addGestureOnTwitterView];
        //[self setGradientColorOft];

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    [self hideTwitterBtn:isTwitterUserLogin];

    [Constant hideNetworkIndicator];

    lblTwitterName.text = userProfile.userName;

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask_Link.png"]];
            imgVwTwitter.image = imgProfile;
        });
    });
}

#pragma mark - Handle swipe on twitter
/**************************************************************************************************
 Function to handle swipe on twitter
 **************************************************************************************************/

- (void)swipeHandleOfTwitter:(UISwipeGestureRecognizer *)swipeRecognizer {

    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {

        [UIView animateWithDuration:0.5 animations:^ {

            vwTwitter.frame = CGRectMake(60, vwTwitter.frame.origin.y, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
            btnTwitter.frame =  CGRectMake(0, vwTwitter.frame.origin.y, 60, vwTwitter.frame.size.height);
        }];
    } else {
        vwTwitter.frame = CGRectMake(0, vwTwitter.frame.origin.y, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
        btnTwitter.frame =  CGRectMake(-60, vwTwitter.frame.origin.y, 60, vwTwitter.frame.size.height);
    }
}

#pragma amrk - Instagram btn tapped
/**************************************************************************************************
 Function to instagram btn tapped
 **************************************************************************************************/

- (IBAction)instagramBtnTapped:(id)sender {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    [Constant showNetworkIndicator];

    // here i can set accessToken received on previous login
    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;
    NSLog(@"%@",  sharedAppDelegate.InstagramId);
    if ([sharedAppDelegate.instagram isSessionValid]) {

        if (sharedAppDelegate.InstagramId.length == 0) {

                // api.instagram.com/v1/users/self?
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self", @"method", nil]; //fetch feed
            [sharedAppDelegate.instagram requestWithParams:params
                                                  delegate:self];
            return;
        }
        
//        NSString *strInstagrameUserId = [NSString stringWithFormat:@"users/%@",sharedAppDelegate.InstagramId];
//        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strInstagrameUserId, @"method", nil]; //fetch feed
//        [sharedAppDelegate.instagram requestWithParams:params
//                                                  delegate:self];
//        return;
    } else {

        [Constant hideNetworkIndicator];
        [self login];
//        UIAlertView *alertVw = [[UIAlertView alloc]initWithTitle:@"Instagrame" message:@"Are You want to open Instagrame through safari." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
//        [alertVw show];
    }
}

#pragma mark - UIAlert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
}

#pragma mark - Login

- (void)login {

    [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

#pragma - IGSessionDelegate

- (void)igDidLogin {

    NSLog(@"Instagram did login");
        // here i can store accessToken
    [[NSUserDefaults standardUserDefaults] setObject:sharedAppDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];

    [self instagramBtnTapped:nil];
}

- (void)igDidNotLogin:(BOOL)cancelled {

    NSLog(@"Instagram did not login");
    NSString* message = nil;
    if (cancelled) {
        message = @"Access cancelled!";
    } else {
        message = @"Access denied!";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)igDidLogout {

    NSLog(@"Instagram did logout");
        // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)igSessionInvalidated {

    NSLog(@"Instagram session was invalidated");
}

#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {

    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {

        //    if (sharedAppDelegate.InstagramId.length == 0) {
            //    NSArray *arry = [result objectForKey:@"data"];
//    if (arry.count == 0) {
//
//        [sharedAppDelegate.spinner hide:YES];
//        return;
//    }
//    NSString *strInstagrameId = [NSString stringWithFormat:@"%@", [[[[arry objectAtIndex:0] valueForKey:@"caption"]valueForKey:@"from"]valueForKey:@"id"]];
//    sharedAppDelegate.InstagramId = strInstagrameId;
//    NSString *strInstagrameUserId = [NSString stringWithFormat:@"users/%@",sharedAppDelegate.InstagramId];
//    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strInstagrameUserId, @"method", nil]; //fetch feed
//    [sharedAppDelegate.instagram requestWithParams:params
//                                          delegate:self];
//    }
//
//    NSLog(@"Instagram did load: %@", result);
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISINSTAGRAMLOGIN];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [self convertInstagramProfileData:[result objectForKey:@"data"]];
}

#pragma mark - Convert profile Info of instagram
/**************************************************************************************************
 Function to convert profile Info of instagram
 **************************************************************************************************/

- (void)convertInstagramProfileData:(NSDictionary *)dictInfo {

    UserProfile *userProfile = [[UserProfile alloc]init];
    if ([dictInfo isKindOfClass: [NSDictionary class]]) {

        NSDictionary *dictCounts = [dictInfo objectForKey:@"counts"];
        userProfile.followers = [NSString stringWithFormat:@"%li",(long)[[dictCounts valueForKey:@"followed_by"] integerValue]];
        userProfile.following = [NSString stringWithFormat:@"%li",(long)[[dictCounts valueForKey:@"follows"]integerValue]];
        userProfile.post = [NSString stringWithFormat:@"%li",(long)[[dictCounts valueForKey:@"media"] integerValue]];
        userProfile.userId = [NSString stringWithFormat:@"%li",(long)[[dictInfo valueForKey:@"id"] integerValue]];
        userProfile.userImg = [dictInfo valueForKey:@"profile_picture"];
        userProfile.userName = [dictInfo valueForKey:@"username"];
        userProfile.type = @"Instagram";
        userProfile.description = [dictInfo valueForKey:@"bio"];
        [[NSUserDefaults standardUserDefaults]setValue:userProfile.userId forKey:@"InstagramId"];
        [[NSUserDefaults standardUserDefaults]synchronize];

        sharedAppDelegate.InstagramId = userProfile.userId;
        
        [self setInstagramUserInfo:userProfile];
        [userProfile saveUserProfile];
    }
}

#pragma mark - Back btn tapped
/**************************************************************************************************
 Function to back btn tapped
 **************************************************************************************************/

- (IBAction)backBtnTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Set instagram user info
/**************************************************************************************************
 Function to set instagram user info
 **************************************************************************************************/

- (void)setInstagramUserInfo:(UserProfile*)userProfile {

    [self addGestureOnInstagram];
    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    [self hideInstagramBtn:isInstagramUserLogin];

    [Constant hideNetworkIndicator];
    lblInstagramName.text = userProfile.userName;

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask_Link.png"]];
            imgVwInstagram.image = imgProfile;
        });
    });
}

#pragma mark - Add gesture on instagram

- (void)addGestureOnInstagram {

    UISwipeGestureRecognizer * swiperightInst = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandleOfInstagram:)];
    swiperightInst.direction = UISwipeGestureRecognizerDirectionRight;
    [vwInstagram addGestureRecognizer:swiperightInst];

    UISwipeGestureRecognizer * swipeleftInt = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeHandleOfInstagram:)];
    swipeleftInt.direction=UISwipeGestureRecognizerDirectionLeft;
    [vwInstagram addGestureRecognizer:swipeleftInt];
}

- (void)swipeHandleOfInstagram:(UISwipeGestureRecognizer *)swipeRecognizer {

    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {

        [UIView animateWithDuration:0.5 animations:^ {

            vwInstagram.frame = CGRectMake(60, vwInstagram.frame.origin.y, vwInstagram.frame.size.width, vwInstagram.frame.size.height);
            btnInstagram.frame =  CGRectMake(0, vwInstagram.frame.origin.y, 60, vwInstagram.frame.size.height);
        }];
    } else {
        vwInstagram.frame = CGRectMake(0, vwInstagram.frame.origin.y, vwInstagram.frame.size.width, vwInstagram.frame.size.height);
        btnInstagram.frame =  CGRectMake(-60, vwInstagram.frame.origin.y, 60, vwInstagram.frame.size.height);
    }
}

#pragma mark - Delete fb account from setting
/**************************************************************************************************
 Function to delete fb account from setting
 **************************************************************************************************/

- (IBAction)deleteFBAccout:(id)sender {

    [UserProfile deleteProfile:@"Facebook"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISFBLOGIN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self hideFBBtn:NO];
    [UIView animateWithDuration:0.5 animations:^ {

        vwFB.frame = CGRectMake(0, vwFB.frame.origin.y, vwFB.frame.size.width, vwFB.frame.size.height);
        btnFb.frame =  CGRectMake(-60, btnFb.frame.origin.y, 60, vwFB.frame.size.height);
    }];
}

#pragma mark - Delete twitter account from setting
/**************************************************************************************************
 Function to delete twitter account from setting
 **************************************************************************************************/

- (IBAction)deleteTwitterAccout:(id)sender {

    [UserProfile deleteProfile:@"Twitter"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISTWITTERLOGIN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self hideTwitterBtn:NO];

    [UIView animateWithDuration:0.5 animations:^ {

        vwTwitter.frame = CGRectMake(0, vwTwitter.frame.origin.y, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
        btnTwitter.frame =  CGRectMake(-60, btnTwitter.frame.origin.y, 60, vwTwitter.frame.size.height);
    }];
}

#pragma mark - Delete instagram account from setting
/**************************************************************************************************
 Function to delete instagram account from setting
 **************************************************************************************************/

- (IBAction)deleteInstagramAccout:(id)sender {

    [UserProfile deleteProfile:@"Instagram"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:ISINSTAGRAMLOGIN];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"InstagramId"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    sharedAppDelegate.InstagramId = nil;

    [self hideInstagramBtn:NO];

    [self igDidLogout];
    [UIView animateWithDuration:0.5 animations:^ {

        vwInstagram.frame = CGRectMake(0, vwInstagram.frame.origin.y, vwInstagram.frame.size.width, vwInstagram.frame.size.height);
        btnInstagram.frame =  CGRectMake(-60, btnInstagram.frame.origin.y, 60, vwInstagram.frame.size.height);
    }];
}

@end

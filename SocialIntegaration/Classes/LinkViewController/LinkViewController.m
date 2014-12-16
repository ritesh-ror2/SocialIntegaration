//
//  LinkViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "LinkViewController.h"
#import "Constant.h"
#import "ViewController.h"
#import "Reachability.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import <Social/Social.h>

@interface LinkViewController () <IGRequestDelegate, IGSessionDelegate> {

    ViewController *vwController;
}

@end

@implementation LinkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;

    btnFb.hidden = YES;
    btnInstagram.hidden = YES;
    btnTwitter.hidden = YES;

    [self userLoginOrNot];

    if (IS_IPHONE_6_IOS8 || IS_IPHONE_6P_IOS8) {
        [self setFrameOfViewsForiPhone6And6plus];
    } else {

        BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
        if (isFbLogin == YES)  {
            vwFB.frame = CGRectMake (0, vwFB.frame.origin.y-50, vwFB.frame.size.width, vwFB.frame.size.height);
        }

        BOOL isTwitterLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
        if (isTwitterLogin == YES)  {
            vwTwitter.frame = CGRectMake (0, 0, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
        } else {
            vwTwitter.frame = CGRectMake (0, 112, vwTwitter.frame.size.width, vwTwitter.frame.size.height);
        }

        BOOL isInstLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
        if (isInstLogin == YES)  {
            vwInstagram.frame = CGRectMake (0, 0, vwInstagram.frame.size.width,200);
        } else {
            vwInstagram.frame = CGRectMake (0, 195, vwInstagram.frame.size.width,200);
        }
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

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBarHidden = YES;
    btnFb.hidden = NO;
    btnInstagram.hidden = NO;
    btnTwitter.hidden = NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


- (void)setFrameOfViewsForiPhone6And6plus {

    int yAxis;
    int yAxisOfContent;
    int startFrameInst;
    int startFrameTwit;

    if (IS_IPHONE_6_IOS8) {
        yAxis = 250;
        yAxisOfContent = 35;
        startFrameInst = 230;
        startFrameTwit = 128;
    } else {
        yAxis = 280;
        yAxisOfContent = 55;
        startFrameInst = 245;
        startFrameTwit = 134;
    }

    imgVwTwitterCircle.image = [UIImage imageNamed:@"mask-border.png"];
    imgVwFBCircle.image = [UIImage imageNamed:@"mask-border.png"];
    imgVwInstagramCircle.image = [UIImage imageNamed:@"mask-border.png"];

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == YES) {

        if (IS_IPHONE_6_IOS8) {
            vwTwitter.frame = CGRectMake (0, 30, vwTwitter.frame.size.width, vwTwitter.frame.size.height+20);
        } else {
            vwTwitter.frame = CGRectMake (0, 40, vwTwitter.frame.size.width, vwTwitter.frame.size.height-10);
        }
    } else {
        vwTwitter.frame = CGRectMake (0, startFrameTwit, vwTwitter.frame.size.width, vwTwitter.frame.size.height-10);
    }
    [self.view sendSubviewToBack:vwTwitter];
        //twitter
    imgVwTwitter.frame = CGRectMake((self.view.frame.size.width - 98)/2, imgVwTwitter.frame.origin.y+yAxisOfContent, 98, 98);
    imgVwTwitterCircle.frame = CGRectMake((self.view.frame.size.width - 100)/2, imgVwTwitterCircle.frame.origin.y+yAxisOfContent, 100, 100);
    btnTwitterAdd.frame = CGRectMake((self.view.frame.size.width - btnTwitterAdd.frame.size.width)/2, btnTwitterAdd.frame.origin.y+yAxisOfContent+yAxisOfContent+10, btnTwitterAdd.frame.size.width, btnTwitterAdd.frame.size.height);
    lblTwitterName.frame = CGRectMake(lblFBName.frame.origin.x, imgVwTwitter.frame.origin.y + imgVwTwitter.frame.size.height + 5, lblTwitterName.frame.size.width, lblTwitterName.frame.size.height);
    lblTwitterTitle.frame = CGRectMake(lblTwitterTitle.frame.origin.x, lblTwitterName.frame.origin.y + lblTwitterName.frame.size.height + 5, lblTwitterTitle.frame.size.width, lblTwitterTitle.frame.size.height);

    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbLogin == YES) {  //facebook
        vwFB.frame = CGRectMake (0, 0, vwFB.frame.size.width, vwFB.frame.size.height-10);
    }
        imgVwFB.frame = CGRectMake((self.view.frame.size.width - 98)/2, imgVwFB.frame.origin.y, 98, 98);
        imgVwFBCircle.frame = CGRectMake((self.view.frame.size.width - 100)/2, imgVwFBCircle.frame.origin.y, 100, 100);
        btnFbAdd.frame = CGRectMake((self.view.frame.size.width - btnTwitterAdd.frame.size.width)/2, btnFbAdd.frame.origin.y+70, btnFbAdd.frame.size.width, btnFbAdd.frame.size.height);
        lblFBName.frame = CGRectMake(lblFBName.frame.origin.x, imgVwFB.frame.origin.y + imgVwFB.frame.size.height + 5, lblFBName.frame.size.width,lblFBName.frame.size.height);
        lblFBTitle.frame = CGRectMake(lblFBTitle.frame.origin.x, lblFBName.frame.origin.y + lblFBName.frame.size.height + 5, lblFBTitle.frame.size.width, lblFBTitle.frame.size.height);

    BOOL isInstUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    if (isInstUserLogin == YES) {
        vwInstagram.frame = CGRectMake (0, 0, vwInstagram.frame.size.width, vwInstagram.frame.size.height+10);
    } else {
        vwInstagram.frame = CGRectMake (0,startFrameInst , vwInstagram.frame.size.width, vwInstagram.frame.size.height+20);
    }

        //instagram
    imgVwInstagram.frame = CGRectMake((self.view.frame.size.width - 98)/2, imgVwInstagram.frame.origin.y-yAxisOfContent+12, 98, 98);
    imgVwInstagramCircle.frame = CGRectMake((self.view.frame.size.width - 100)/2, imgVwInstagramCircle.frame.origin.y-yAxisOfContent+12, 100, 100);
    btnInstagramAdd.frame = CGRectMake((self.view.frame.size.width - btnInstagramAdd.frame.size.width)/2, btnInstagramAdd.frame.origin.y-20, btnInstagramAdd.frame.size.width, btnInstagramAdd.frame.size.height);
    lblInstagramName.frame = CGRectMake(lblInstagramName.frame.origin.x, imgVwInstagram.frame.origin.y + imgVwInstagram.frame.size.height +5, lblInstagramName.frame.size.width, lblInstagramName.frame.size.height);
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

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    btnFb.hidden = YES;
    btnInstagram.hidden = YES;
    btnTwitter.hidden = YES;
        //self.navigationController.navigationBarHidden = YES;
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

        imgVwTwitter.alpha = 0.0;
        imgVwTwitterCircle.alpha = 0.0;
        lblTwitterName.alpha = 0.0;
        vwTwitter.alpha = 0.0;

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

        imgVwFB.alpha = 0.0;
        imgVwFBCircle.alpha = 0.0;
        lblFBName.alpha = 0.0;
        vwFB.alpha = 0.0;

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

        imgVwInstagram.alpha = 0.0;
        imgVwInstagramCircle.alpha = 0.0;
        lblInstagramName.alpha = 0.0;
        vwInstagram.alpha = 0.0;

        [imgVwInstagram setHidden:YES];
        [imgVwInstagramCircle setHidden:YES];
        lblInstagramName.hidden = YES;
    }
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

    FBRequest *request = [FBRequest requestForGraphPath:@"me"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {

            [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
            [Constant hideNetworkIndicator];
        } else {

            NSDictionary *dictInfo = (NSDictionary *)result;
            [self getProfileImg:dictInfo];
        }
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

    vwFB.frame = CGRectMake (0, 34, vwFB.frame.size.width, vwFB.frame.size.height-10);

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

        // vwFB.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    [self setGradientColorOfFB];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [vwFB setAlpha:1];
    [imgVwFB setAlpha:1.0];
    [imgVwFBCircle setAlpha:1.0];
    [lblFBName setAlpha:1.0];
    [lblFBTitle setAlpha:1.0];
    [UIView commitAnimations];
    [UIView commitAnimations];

    [lblFBTitle setHidden:NO];

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

                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"There is some authentication problem" delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles: nil];
                            [alert show];
                            [Constant hideNetworkIndicator];
                            return;
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

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    [self hideTwitterBtn:isTwitterUserLogin];

        // vwTwitter.frame = CGRectMake (0, 34, vwTwitter.frame.size.width, vwTwitter.frame.size.height-10);
    [self setGradientColorOfTwitter];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [vwTwitter setAlpha:1];
    [imgVwTwitter setAlpha:1.0];
    [imgVwTwitterCircle setAlpha:1.0];
    [lblTwitterName setAlpha:1.0];
    [lblTwitterTitle setAlpha:1.0];
    [UIView commitAnimations];
    
    [lblTwitterTitle setHidden:NO];

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
        UIAlertView *alertVw = [[UIAlertView alloc]initWithTitle:@"Instagrame" message:@"Are You want to open Instagrame through safari." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
        [alertVw show];
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

    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    [self hideInstagramBtn:isInstagramUserLogin];

        //vwInstagram.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    [self setGradientColorOfInstagram];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [vwInstagram setAlpha:1];
    [imgVwInstagram setAlpha:1.0];
    [imgVwInstagramCircle setAlpha:1.0];
    [lblInstagramName setAlpha:1.0];
    [lblInstagramTitle setAlpha:1.0];
    [UIView commitAnimations];

    [lblInstagramTitle setHidden:NO];

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

- (IBAction)doneBtnTapped:(id)sender{

    [self performSegueWithIdentifier:@"tabbar1" sender:nil];
}
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"tabbar1"]){
        vwController = [segue destinationViewController];
    }
}

#pragma mark - Instagram cell gradient
/**************************************************************************************************
 Function to set instagram cell gradient
 **************************************************************************************************/

- (void)setGradientColorOfInstagram {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = vwInstagram.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:56/255.0f green:94/256.0f blue:135/256.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:61/255.0f green:124/255.0f blue:177/255.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:61/255.0f green:125/255.0f blue:178/255.0f alpha:1.0]CGColor], nil];
    [vwInstagram.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Twitter cell gradient
/**************************************************************************************************
 Function to set twitter cell gradient
 **************************************************************************************************/

- (void)setGradientColorOfTwitter {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = vwTwitter.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:70/255.0f green:144/256.0f blue:241/256.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:74/255.0f green:146/255.0f blue:244/255.0f alpha:1.0] CGColor], (id)[[UIColor colorWithRed:75/255.0f green:160/255.0f blue:245/255.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:80/255.0f green:172/255.0f blue:247/255.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:87/255.0f green:179/255.0f blue:249/255.0f alpha:1.0] CGColor], nil];
    [vwTwitter.layer insertSublayer:gradient atIndex:0];
}


#pragma mark - FB cell gradient
/**************************************************************************************************
 Function to set fb cell gradient
 **************************************************************************************************/

- (void)setGradientColorOfFB {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = vwFB.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:59/255.0f green:90/256.0f blue:153/256.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:66/255.0f green:99/255.0f blue:159/255.0f alpha:1.0]CGColor] ,(id)[[UIColor colorWithRed:75/255.0f green:114/255.0f blue:195/255.0f alpha:1.0] CGColor], (id)[[UIColor colorWithRed:79/255.0f green:120/255.0f blue:204/255.0f alpha:1.0] CGColor], nil];
    [vwFB.layer insertSublayer:gradient atIndex:0];
}

@end

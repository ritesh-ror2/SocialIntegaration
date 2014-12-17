
    //
//  ViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ViewController.h"
#import "UserInfo.h"
#import "FeedPagesViewController.h"
#import "AppDelegate.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import "CommentViewController.h"
#import "ShowOtherUserProfileViewController.h"
#import "Reachability.h"
#import "HYCircleLoadingView.h"
#import "ShareCommentAndMessageViewController.h"

NSString *const kSocialServices = @"SocialServices";
NSString *const kFBSetup = @"FBSetup";

@interface ViewController () {

    BOOL isInstagramOpen;
    BOOL isShowLoading;

    NSMutableData *fbData;
    NSMutableURLRequest *fbRequest;
    NSURLConnection *connetion;

    BOOL isFirstPageFeedsOfFb;
    BOOL isFirstPageTweetsOfTwitter;

    UINavigationBar *navBar;
    UITabBar *tabbar;

    int heightOfRowImg;
    int widthOfCommentLbl;
}

@property (nonatomic)BOOL noMoreResultsAvail;
@property (nonatomic, strong) HYCircleLoadingView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;

@end

@implementation ViewController

BOOL hasTwitter = NO;

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];

    //right button
    UIBarButtonItem *barBtnEdit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];
    self.navItem.rightBarButtonItem = barBtnEdit;

    if (sharedAppDelegate.isFirstTimeLaunch == YES) {

        self.navigationController.navigationBar.hidden = YES;
        self.navController.navigationBar.translucent = YES;// NO;
        self.tbleVwPostList.hidden = YES;
        self.tbleVwPostList.alpha = 0.0;
    } else {

        self.tbleVwPostList.hidden = NO;
        self.tbleVwPostList.alpha = 1.0;
        self.imgVwBackground.hidden = YES;
    }

    //left button
    UIBarButtonItem *barBtnProfile = [[UIBarButtonItem alloc]initWithCustomView:[self addUserImgAtLeftSide]];
   self.navItem.leftBarButtonItem = barBtnProfile;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appIsInForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];

    /// if (IS_IPHONE5) {
        self.imgVwBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    if (!IS_IPHONE5) {
        self.imgVwBackground.image = [UIImage imageNamed:@"Splash-Screen2.png"];
    }

    // }
    // self.loadingView = [[HYCircleLoadingView alloc]init];
    // [self.view addSubview:self.loadingView];
    // [self.view bringSubviewToFront:self.loadingView];
    // self.loadingView.hidden = YES;
    self.tbleVwPostList.separatorColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    BOOL isInstagram = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];

    int yAxisOfLoader;
    if (sharedAppDelegate.isFirstTimeLaunch) {
        yAxisOfLoader = 107;
    } else {
        yAxisOfLoader = 130;
    }
   [self.loadingView setFrame:CGRectMake((self.view.frame.size.width - 70)/2, (self.view.frame.size.height - yAxisOfLoader)/2, 70, 70)];
    heightOfRowImg = [Constant heightOfCellInTableVw];
    widthOfCommentLbl = [Constant widthOfCommentLblOfTimelineAndProfile];

        //self.navigationController.navigationBar.translucent = NO;
        // self.navigationController.navigationBar.hidden = YES;
    [self.arrySelectedIndex removeAllObjects];
    [self.arryTappedCell removeAllObjects];
    [self.tbleVwPostList reloadData];

    if(self.arryTappedCell.count == 0) { //return from other view
        for (NSString *cellSelected in sharedAppDelegate.arryOfAllFeeds) {
            NSLog(@"%@", cellSelected);
            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }

    isFirstPageFeedsOfFb = YES;
    isFirstPageTweetsOfTwitter = YES;

    if (sharedAppDelegate.isFirstTimeLaunch == YES) {

        if (isShowLoading == NO) {
            if(isFbLogin == YES || isTwitter == YES || isInstagram == YES) {
                isShowLoading = YES;
                [self performSelector:@selector(showAnimationView) withObject:nil afterDelay:2.5];
            }
        }
        [self hideNavBar:YES];
         self.imgVwBackground.hidden = NO;
    } else {

        self.navigationController.navigationBar.hidden = NO;
        self.navController.navigationBar.translucent = NO;

        if (sharedAppDelegate.arryOfAllFeeds.count == 0) {

            isShowLoading  = YES;
            [self performSelector:@selector(showAnimationView) withObject:nil afterDelay:0.0];
        }
        [self hideNavBar:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    self.navigationController.navigationBar.hidden = YES;
    if (sharedAppDelegate.isFirstTimeLaunch == YES) {

        self.navController.navigationBar.translucent = YES;
        navBar.frame = CGRectMake(0,-navBar.frame.size.height, navBar.frame.size.width,  navBar.frame.size.height);
        self.tbleVwPostList.alpha = 0.0;
        sharedAppDelegate.isFirstTimeLaunch = NO;
        [self performSelector:@selector(animationOfTimeline) withObject:nil afterDelay:0.0]; // animate
    } else {

        self.navigationController.navigationBar.hidden = NO;
        self.navController.navigationBar.translucent = NO;
        self.tbleVwPostList.hidden = NO;
        self.tbleVwPostList.alpha = 1.0;
        self.imgVwBackground.hidden = YES;
    }

    [self appIsInForeground:nil];

    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:INDEX_OF_PAGE];
    [[NSUserDefaults standardUserDefaults]synchronize];

    self.navItem.title = @"Timeline";
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Navigation bar hide or show

- (void)hideNavBar:(BOOL)isHidden {

    self.navController.navigationBarHidden = isHidden;
}

#pragma mark - Compose message to post on fb and twitter
/**************************************************************************************************
 Function to compose message to post on fb and twitter
 **************************************************************************************************/

- (IBAction)composeMessage:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareCommentAndMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"sharecomment"];
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark - Add user image in left side
/**************************************************************************************************
 Function to show login user image in left side
 **************************************************************************************************/

- (UIImageView *)addUserImgAtLeftSide {

    //add mask image
    UserProfile *userProfile = [UserProfile getProfile:@"Facebook"];

    if (userProfile != nil) {

            NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];
            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
            imgVwProile.frame = CGRectMake(0, 0, 35, 35);
            return imgVwProile;
    }
    UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed: @"user-selected.png"] withMask:[UIImage imageNamed:@"list-mask.png"]];
    UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
    imgVwProile.frame = CGRectMake(0, 0, 35, 35);
    return imgVwProile;
}

/*- (void)appIsInBackground:(NSNotification *)notification {

    [self hideNavBar:YES];
    navBar.frame = CGRectMake(0,-navBar.frame.size.height, navBar.frame.size.width,  navBar.frame.size.height);
    tabbar.hidden = YES;
    tabbar.frame = CGRectMake(tabbar.frame.origin.x, 568, tabbar.frame.size.width,  tabbar.frame.size.height);

    self.imgVwBackground.hidden = NO;
    [self.view bringSubviewToFront:self.imgVwBackground];
    self.tbleVwPostList.hidden = YES;
}*/

#pragma mark - App is in ForeGround
/**************************************************************************************************
 Function to call when app come in foregroud from backgroung
 **************************************************************************************************/

- (void)appIsInForeground:(id)sender {

    if (isInstagramOpen == YES) { //if it only get data from instagram
        isInstagramOpen = NO;
    }

    [Constant showNetworkIndicator];
    // [self getInstagrameIntegration];
    [self showFacebookPost];
}

#pragma mark - Show animation of table view
/**************************************************************************************************
 Function to show table view fade out animation
 **************************************************************************************************/

- (void)animationOfTimeline {

    [self animationOfNavsarAndTabbar];
}

- (void)showAnimationOfFeedTableView {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.tbleVwPostList setHidden:NO];
    [UIView setAnimationDuration:3.0];
    [self.tbleVwPostList setAlpha:1];
    self.tbleVwPostList.hidden = NO;
    [UIView commitAnimations];

//    self.loadingView.hidden = YES;
//    [self.loadingView stopAnimation];
}

- (void)showAnimationView {

    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    BOOL isInstagram = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    if(isFbLogin == YES || isTwitter == YES || isInstagram == YES) {

        self.loadingView.hidden = NO;
        [self.loadingView startAnimation];
    }
}

#pragma mark - Show animation of navbar and tabbar
/**************************************************************************************************
 Function to perform animation of navigation bar and tab bar
 **************************************************************************************************/

- (void)animationOfNavsarAndTabbar {

    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    float animationDuration;
    if(statusBarFrame.size.height > 20) { // in-call
        animationDuration = 0.8;
    } else { // normal status bar
        animationDuration = 0.8;
    }

    navBar = self.navController.navigationBar;
    [self hideNavBar:NO];
    navBar.frame = CGRectMake(0,-navBar.frame.size.height, navBar.frame.size.width,  navBar.frame.size.height);//set navbar custom frame

    tabbar.hidden = NO;
    tabbar = self.tabBarController.tabBar;
    tabbar.frame = CGRectMake(tabbar.frame.origin.x,(self.view.frame.size.height+37), tabbar.frame.size.width,  tabbar.frame.size.height); //set tabbar custom frame

    if (YES) {

        // [[UIApplication sharedApplication]setStatusBarHidden:NO];
        [UIView animateWithDuration:animationDuration animations:^{

            navBar.frame = CGRectMake(0, 20,  navBar.frame.size.width,  navBar.frame.size.height);
            tabbar.frame = CGRectMake(tabbar.frame.origin.x, (self.view.frame.size.height+37) - tabbar.frame.size.height, tabbar.frame.size.width,  tabbar.frame.size.height);
            self.navController.navigationBar.hidden = NO;

        } completion:^(BOOL finished) {
            self.navController.navigationBar.translucent = YES;//NO;

            if (sharedAppDelegate.arryOfAllFeeds.count == 0) {
                    //[Constant hideNetworkIndicator];
            }
        }];
    }
}

#pragma mark - Check session of facebook
/**************************************************************************************************
 Function to perform animation of navigation bar and tab bar
 **************************************************************************************************/

- (void)showFacebookPost {

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

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

        dispatch_async(dispatch_get_main_queue(), ^{

            [sharedAppDelegate.arryOfFBNewsFeed removeAllObjects];
            //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB ];
            [self getTweetFromTwitter];
        });
        return;
    } else {
            // if (isShowLoading == NO) {

                // isShowLoading = YES;
                // [self  performSelector:@selector(showAnimationView) withObject:nil afterDelay:2.5];
                //}
        [FBSettings setDefaultAppID:FB_APP_ID];
        [FBAppEvents activateApp];

        if (FBSession.activeSession.state == FBSessionStateOpen ||
		    FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
			sharedAppDelegate.fbSession = FBSession.activeSession;
			sharedAppDelegate.hasFacebook = YES;
		}
    }
	[self updatePosts];
}

#pragma mark - User profile btn tapped
/**************************************************************************************************
 Function to show other user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    /*   NSString *strUserId = [NSString stringWithFormat:@"/%@",userInfo.fromId];
        [FBRequestConnection startWithGraphPath:strUserId parameters:nil HTTPMethod:@"GET"
           completionHandler:^( FBRequestConnection *connection, id result,  NSError *error ) {
                if (error) {

                  } else {
                      NSDictionary *dictProfile = (NSDictionary *)result;

                      UserInfo *otherUserInfo = [[UserInfo alloc]init];
                      otherUserInfo.strUserName = [dictProfile valueForKey:@"name"];
                      otherUserInfo.fromId  = [dictProfile valueForKey:@"id"];
                      otherUserInfo.strUserSocialType = @"Facebook";}*/

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
      vwController.userInfo = userInfo;
    vwController.navController =  self.navController;
    [self.navigationController pushViewController:vwController animated:YES];
}

#pragma mark - Login with facebook
/**************************************************************************************************
 Function to login on facebook
 **************************************************************************************************/

- (void)loginFacebook {

    [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info",  @"read_stream", @"email", @"user_friends", @"user_likes"]  allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
	                                                  FBSessionState state,
	                                                  NSError *error) {
                                      if (error) {

                                          sharedAppDelegate.hasFacebook = NO;
                                          [self getTweetFromTwitter];
                                            // [sharedAppDelegate.spinner hide:YES];
                                      } else {

                                          sharedAppDelegate.fbSession = session;
                                          sharedAppDelegate.hasFacebook = YES;

                                          [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISFBLOGIN];
                                          [[NSUserDefaults standardUserDefaults]synchronize];

                                          [self getNewsfeedOfFB];
                                      }
		                          }];
}

#pragma mark - Call News feed function
/**************************************************************************************************
 Function call to get news feed function of fB
 **************************************************************************************************/

- (void)updatePosts {

	[self getNewsfeedOfFB];
}

#pragma mark - Get news feed of facebook
/**************************************************************************************************
 Function to get news feed of FB
 **************************************************************************************************/

- (void)getNewsfeedOfFB {

    if (!sharedAppDelegate.hasFacebook) {
		[self loginFacebook];
		return;
	}

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"access_token"] = sharedAppDelegate.fbSession.accessTokenData;

	FBRequest *request = [FBRequest requestForGraphPath:@"me/home"];
    [FBSession setActiveSession:sharedAppDelegate.fbSession];

	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // NSLog(@"%@", [error description]);
		if (error) {

            // [Constant showAlert:ERROR_CONNECTING forMessage:@"Feeds is not comming"];
            [self getTweetFromTwitter];
		} else {

            NSArray *arryPost = [result objectForKey:@"data"];
            sharedAppDelegate.nextFbUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];//next oage url of facebook
            [self convertDataOfFBIntoModel:arryPost];
		}
	}];
}

#pragma mark - Convert array of FB  data into model class
/**************************************************************************************************
 Function to Convert dictionary in array of FB  data into model class
 **************************************************************************************************/

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    if (isFirstPageFeedsOfFb == YES) { //at first time only remove all object
        [sharedAppDelegate.arryOfFBNewsFeed removeAllObjects];
    }
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *fromUser = [dictData objectForKey:@"from"];

            userInfo.userName = [fromUser valueForKey:@"name"];
            userInfo.fromId = [fromUser valueForKey:@"id"];
            userInfo.userSocialType = @"Facebook";
            userInfo.fbLike = [[dictData valueForKey:@"user_likes"] boolValue];
            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.strUserPost = [dictData valueForKey:@"message"];
            userInfo.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
            userInfo.postImg = [dictData valueForKey:@"picture"];
            userInfo.postId = [dictData valueForKey:@"id"];
            userInfo.videoUrl = [dictData valueForKey:@"source"];

            if (![[dictData objectForKey:@"type"] isEqualToString:@"video"] && ![[dictData objectForKey:@"type"] isEqualToString:@"photo"]) {
                userInfo.objectIdFB = [dictData valueForKey:@"id"];
             } else {
                 userInfo.objectIdFB = [dictData valueForKey:@"object_id"];
             }
            [sharedAppDelegate.arryOfFBNewsFeed addObject:userInfo];
        }
    }
    if (isFirstPageFeedsOfFb == YES) {
        [self getTweetFromTwitter];
    } else {
        [self shortArryOfAllFeeds];
    }
}

#pragma mark - Get Tweets from twitter
/**************************************************************************************************
 Function to get twets from twitter
 **************************************************************************************************/

- (void)getTweetFromTwitter {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == NO) {

        NSArray *arryVwController = self.navController.viewControllers;
        UIViewController *vwController = [arryVwController lastObject];

        if ([vwController isKindOfClass:[FeedPagesViewController class]]) { //if this view controller is currently tapped
            if (self.tabBarController.selectedViewController == self.navigationController) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        //  [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
                });
            }
        }

        [sharedAppDelegate.arryOfTwittes removeAllObjects];
            // NSLog(@" ** %i", sharedAppDelegate.arryOfAllFeeds.count);
        [self getInstagrameIntegration];
        return;
    } else {

        if (isShowLoading == NO) {
                //  [self showAnimationView];
        }

        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account
                                      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error) {
           if (granted == YES) {
               NSArray *arrayOfAccounts = [account
                                           accountsWithAccountType:accountType];

               if ([arrayOfAccounts count] > 0) {

                   sharedAppDelegate.twitterAccount = [arrayOfAccounts lastObject];
                    // NSDictionary* params = @{@"count": @"50"};

                   NSURL *requestURL = [NSURL URLWithString:TWITTER_TIMELINE_URL];
                   SLRequest *timelineRequest = [SLRequest
                                                 requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:SLRequestMethodGET
                                                 URL:requestURL parameters:nil];

                   timelineRequest.account = sharedAppDelegate.twitterAccount;

                   [timelineRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

                       if(!error) {

                           id result = [NSJSONSerialization
                                                 JSONObjectWithData:responseData
                                                 options:NSJSONReadingMutableLeaves
                                                 error:&error];

                           NSArray *arryTwitte  = (NSArray *)result;
                          if (arryTwitte.count != 0) {
                              dispatch_async(dispatch_get_main_queue(), ^{

                                  [self convertDataOfTwitterIntoModel: arryTwitte];//convert into model class
                              });
                          } else {
                              dispatch_async(dispatch_get_main_queue(), ^{

                                // [Constant showAlert:@"Message" forMessage:@"No Tweet in your account."];
                              });
                              [self getInstagrameIntegration];
                          }
                       }
                    }];
                 }
           } else {
           }
         }];
    }
}

#pragma mark - Pagging in twitter for more tweets
/**************************************************************************************************
 Function to get more tweets of other pages from twitter
 **************************************************************************************************/

- (void)paggingInTwitter {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    //The max_id = top of tweets id list . since_id = bottom of tweets id list .
    //TWITTER_TIMELINE_URL since_id=24012619984051000&max_id=250126199840518145&result_type=recent&count=10

    if (sharedAppDelegate.arryOfTwittes.count > 0) {
    UserInfo *userInfo = [sharedAppDelegate.arryOfTwittes objectAtIndex:0];
    int max_Id = userInfo.statusId.intValue;

    UserInfo *userInfoSince = [sharedAppDelegate.arryOfTwittes objectAtIndex:sharedAppDelegate.arryOfTwittes.count - 1];//[sharedAppDelegate.arryOfTwittes objectAtIndex:0];
    int since_Id = userInfoSince.statusId.intValue;

        NSDictionary* params = @{@"since_id":[NSNumber numberWithInt:since_Id], @"max_id":[NSNumber numberWithInt:max_Id]};//@"count":@"30"

    NSURL *requestURL = [NSURL URLWithString:TWITTER_USER_OWN_STATUS];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:params];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

            //NSLog(@"%@ !#" , [error description]);
        if (!error) {

            id result = [NSJSONSerialization
                        JSONObjectWithData:responseData
                        options:NSJSONReadingMutableLeaves
                        error:&error];

           if (![result isKindOfClass:[NSDictionary class]]) {

               isFirstPageTweetsOfTwitter = NO;
               NSArray *arryTwitte = (NSArray *)result;
               [self convertDataOfTwitterIntoModel:arryTwitte];
           } else {

                   //  NSLog(@"error %@", result);
           }
        } else {
            [Constant showAlert:@"Message" forMessage:@"The Internet connection appears to be offline."];
        }
     }];
    }
}


#pragma mark - Convert array of twitter response in to model class
/**************************************************************************************************
 Function to convert array of twitter response in to model class
 **************************************************************************************************/

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    if (isFirstPageTweetsOfTwitter == YES) {
        [sharedAppDelegate.arryOfTwittes removeAllObjects];
    }

    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];
            UserInfo *userInfo =[[UserInfo alloc]init];
            userInfo.userName = [postUserDetailDict valueForKey:@"name"];
            userInfo.fromId = [postUserDetailDict valueForKey:@"id"];
            userInfo.userProfileImg = [postUserDetailDict valueForKey:@"profile_image_url"];

            NSArray *arryMedia = [[dictData objectForKey:@"extended_entities"] objectForKey:@"media"];

            if (arryMedia.count>0) {
                userInfo.postImg = [[arryMedia objectAtIndex:0] valueForKey:@"media_url"];
            }
            userInfo.strUserPost = [dictData valueForKey:@"text"];
            userInfo.userSocialType = @"Twitter";
            userInfo.type = [dictData objectForKey:@"type"];
            NSString *strDate = [Constant convertDateOfTwitterInDatabaseFormate:[dictData objectForKey:@"created_at"]];
            userInfo.time = [Constant convertDateOFTwitter:strDate];
            userInfo.statusId = [dictData valueForKey:@"id"];
            userInfo.favourated = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"favorited"] integerValue]];
            userInfo.screenName = [postUserDetailDict valueForKey:@"screen_name"];
            userInfo.retweeted = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"retweeted"] integerValue]];
            userInfo.retweetCount = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"retweet_count"] integerValue]];
            userInfo.favourateCount = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"favorite_count"] integerValue]];
            userInfo.isFollowing = [[postUserDetailDict valueForKey:@"following"]boolValue];
            userInfo.dicOthertUser = postUserDetailDict;
            [sharedAppDelegate.arryOfTwittes addObject:userInfo];
        }
    }

    if (isFirstPageTweetsOfTwitter == YES) {
        [self getInstagrameIntegration];
    } else {
        if (sharedAppDelegate.arryOfFBNewsFeed.count == 0) {
            [self shortArryOfAllFeeds];
        }
    }
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [sharedAppDelegate.arryOfAllFeeds count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"cellIdentifier";
    CustomTableCell *cell;

    cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSArray *arryObjects;
    if (cell == nil) {

        arryObjects = [[NSBundle mainBundle]loadNibNamed:@"CustomTableCell" owner:nil options:nil];
        cell = [arryObjects objectAtIndex:0];
        cell.customCellDelegate = self;
    }

    BOOL isSelected = NO;
    if (self.arryTappedCell.count != 0 && indexPath.row < self.arryTappedCell.count) {
        isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];
    }
    if(indexPath.row < [sharedAppDelegate.arryOfAllFeeds count]){

        self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfAllFeeds objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:NO withOtherTimeline:NO];
    } else {

        if (sharedAppDelegate.arryOfAllFeeds.count != 0) {

            if (self.noMoreResultsAvail == NO) {

                [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:YES withOtherTimeline:NO];
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);

                [self getMoreDataOfFBFeed];
                NSLog(@"twitter %i", isFirstPageTweetsOfTwitter);

                BOOL isTwitterLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
                if (isFirstPageTweetsOfTwitter == YES && isTwitterLogin == YES) {
                    [self paggingInTwitter];
                }
            } else {

                self.noMoreResultsAvail = NO;
            }
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfAllFeeds.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfAllFeeds count]-1) {
            return 60;
        }
    } else {
        return 0;
    }

    UserInfo *objUserInfo = [sharedAppDelegate.arryOfAllFeeds objectAtIndex:indexPath.row];

    NSString *string = [objUserInfo.strUserPost stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(widthOfCommentLbl, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:17.0]}
                                       context:nil];

    if (objUserInfo.postImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + heightOfRowImg + 35);
            }
        }
        return(rect.size.height + heightOfRowImg+13);
    }

    for (NSString *index in self.arrySelectedIndex) {

        if (index.integerValue == indexPath.row) {
            return(rect.size.height + 90);
        }
    }
    return (rect.size.height + 65);//183 is height of other fixed content
}


#pragma mark - Custom Table cell Delegates
/**************************************************************************************************
 Delegete to show when select row at second time after tapped
 **************************************************************************************************/

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}


/**************************************************************************************************
Delegate to increase cell height when cell is tapped
 **************************************************************************************************/

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {
    
    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    NSLog(@"****%i*** %i", self.arryTappedCell.count, sharedAppDelegate.arryOfAllFeeds.count);

    if (self.arryTappedCell.count != 0) {
        if (isSelected == YES) {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
        } else {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
        }
    }
    [self.tbleVwPostList beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwPostList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwPostList endUpdates];
}

#pragma mark - Integrate instagrame
/**************************************************************************************************
 Function to integrate instagram
 **************************************************************************************************/

- (void)getInstagrameIntegration {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    // [self shortArryOfAllFeeds];
    // return;
    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;

    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    if (isInstagramUserLogin == NO) {

        NSArray *arryVwController = self.navController.viewControllers;
        UIViewController *vwController = [arryVwController lastObject];
        
        if ([vwController isKindOfClass:[FeedPagesViewController class]]) { //if this view controller is currently tapped
            if (self.tabBarController.selectedViewController == self.navigationController) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_INSTAGRAM];
                });
            }
        }

        [sharedAppDelegate.arryOfInstagrame removeAllObjects];
        [Constant hideNetworkIndicator];
        [self shortArryOfAllFeeds];
    } else {
        if (isShowLoading == NO) {
                // [self showAnimationView];
        }

        if ([sharedAppDelegate.instagram isSessionValid]) {

            isInstagramOpen = YES;
            NSString *strUrl = [NSString stringWithFormat:@"users/self/feed"];//@"users/%@/media/recent",[ [NSUserDefaults standardUserDefaults]valueForKey:@"InstagramId"]];
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strUrl, @"method", nil]; //fetch feed
            [sharedAppDelegate.instagram requestWithParams:params
                                            delegate:self];
        } else {

        }
    }
}

#pragma mark - Instagram user login
/**************************************************************************************************
 Function to convert array of twitter response in to model class
 **************************************************************************************************/

- (void)login {

    [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

#pragma - IGSessionDelegate

- (void)igDidLogin {

    [[NSUserDefaults standardUserDefaults] setObject:sharedAppDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];

    [self getInstagrameIntegration];
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    isInstagramOpen = NO;
}

- (void)igSessionInvalidated {

    NSLog(@"Instagram session was invalidated");
}

#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {

    [self shortArryOfAllFeeds];

    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)request:(IGRequest *)request didLoad:(id)result {

    // NSLog(@"Instagram did load: %@", result);
    NSArray *arry = [result objectForKey:@"data"];
    [self convertDataOfInstagramIntoModelClass:arry];
}

#pragma mark - Convert data of instagrame in to model class
/**************************************************************************************************
 Function to convert array of instagrame in to model class
 **************************************************************************************************/

- (void)convertDataOfInstagramIntoModelClass:(NSArray *)arryOfInstagrame {

    if (isFirstPageFeedsOfFb == YES) {
        [sharedAppDelegate.arryOfInstagrame removeAllObjects];
    }

    @autoreleasepool {

        for (NSDictionary *dictData in arryOfInstagrame) {

            // NSLog(@" instagrame %@", dictData);
            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"caption"];

            userInfo.strUserPost = [postUserDetailDict valueForKey:@"text"];
            NSString *strDate = [postUserDetailDict objectForKey:@"created_time"];

            NSDictionary *dictUserInfo = [postUserDetailDict objectForKey:@"from"];

            userInfo.userName = [dictUserInfo valueForKey:@"username"];
            userInfo.fromId = [dictUserInfo valueForKey:@"id"];
            sharedAppDelegate.InstagramId = userInfo.fromId;
            userInfo.userProfileImg = [dictUserInfo valueForKey:@"profile_picture"];

            userInfo.mediaIdOfInstagram = [dictData valueForKey:@"id"];
            userInfo.instagramLikeCount = [[dictData objectForKey:@"likes"]valueForKey:@"count"];
            userInfo.instagramCommentCount = [[dictData objectForKey:@"comments"]valueForKey:@"count"];

            NSTimeInterval interval = strDate.doubleValue;
            NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970: interval];
            userInfo.time = [Constant convertDateOFInstagram:convertedDate];

            NSDictionary *dictImage = [dictData objectForKey:@"images"];
            userInfo.postImg = [[dictImage valueForKey:@"low_resolution"]objectForKey:@"url"];

            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.userSocialType = @"Instagram";
            userInfo.statusId = [dictData objectForKey:@"id"];

            [sharedAppDelegate.arryOfInstagrame addObject:userInfo];
        }
    }
    [self shortArryOfAllFeeds];
}

#pragma mark - Short array of news feed 
/**************************************************************************************************
 Function to short array of news feed which include all feeds of twitter, FB and instagram
 **************************************************************************************************/

- (void)shortArryOfAllFeeds {

    dispatch_async(dispatch_get_main_queue(), ^{

        [Constant hideNetworkIndicator];

        if (isShowLoading == YES) {

            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [self.imgVwBackground setAlpha:0];
            [UIView commitAnimations];

            [self.loadingView stopAnimation];
            [self.loadingView setHidden:YES];
        }
    });
    [sharedAppDelegate.arryOfAllFeeds removeAllObjects]; //first remove all object
    NSLog(@"**** %lu",(unsigned long)sharedAppDelegate.arryOfTwittes.count);

    [sharedAppDelegate.arryOfAllFeeds addObjectsFromArray:sharedAppDelegate.arryOfFBNewsFeed];
    [sharedAppDelegate.arryOfAllFeeds addObjectsFromArray:sharedAppDelegate.arryOfTwittes];
    [sharedAppDelegate.arryOfAllFeeds addObjectsFromArray:sharedAppDelegate.arryOfInstagrame];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];//give key name
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSArray *sortedArray = [sharedAppDelegate.arryOfAllFeeds sortedArrayUsingDescriptors:sortDescriptors];
    [sharedAppDelegate.arryOfAllFeeds removeAllObjects];
    sharedAppDelegate.arryOfAllFeeds = [sortedArray mutableCopy];
    NSLog(@"**** %lu",(unsigned long)sharedAppDelegate.arryOfAllFeeds.count);

        // [self.arryTappedCell removeAllObjects];
        // [self.arrySelectedIndex removeAllObjects];

    NSArray *arryTapped = self.arryTappedCell;

     if(self.arryTappedCell.count < sharedAppDelegate.arryOfAllFeeds.count) {

         [self.arryTappedCell removeAllObjects];

         for  (int iLoop=0; iLoop<sharedAppDelegate.arryOfAllFeeds.count; iLoop++) {

             BOOL isSelected = NO;
             if (arryTapped.count >= sharedAppDelegate.arryOfAllFeeds.count) {
                isSelected = [[arryTapped objectAtIndex:iLoop]boolValue];
             }
             [self.arryTappedCell addObject:[NSNumber numberWithBool:isSelected]];
        }
     }
    NSLog(@"%i", self.arryTappedCell.count);

    [self.tbleVwPostList reloadData];
    [self performSelector:@selector(setTranslucentOfNavigationBar) withObject:nil afterDelay:1.0];
    if (sharedAppDelegate.arryOfAllFeeds.count != 0) {
        [self showAnimationOfFeedTableView];
    } else {
        [self.tbleVwPostList setHidden:YES];
    }
}

- (void)setTranslucentOfNavigationBar {

    self.navController.navigationBar.translucent = NO;
}

#pragma mark - Get more data of Fb news feed
/**************************************************************************************************
 Function to get more data of Fb news feed
 **************************************************************************************************/

- (void)getMoreDataOfFBFeed {

    //Get more data of feed
    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbLogin == YES) {

        isFirstPageFeedsOfFb = NO;

        NSURL *fbUrl = [NSURL URLWithString:sharedAppDelegate.nextFbUrl];
        fbRequest = [[NSMutableURLRequest alloc]initWithURL:fbUrl];
        connetion = [[NSURLConnection alloc]initWithRequest:fbRequest delegate:self];
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    fbData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    [fbData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
        // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    self.noMoreResultsAvail = YES;
    id result = [NSJSONSerialization JSONObjectWithData:fbData options:kNilOptions error:nil];
    sharedAppDelegate.nextFbUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];
    [self convertDataOfFBIntoModel:[result objectForKey:@"data"]];
}

@end

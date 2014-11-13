//
//  ViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ViewController.h"
#import "UserInfo.h"
#import "CustomTableCell.h"
#import "Constant.h"
#import "AppDelegate.h"

#import <Social/Social.h>

NSString *const kSocialServices = @"SocialServices";
NSString *const kFBSetup = @"FBSetup";

@interface ViewController () <UIAlertViewDelegate> {

    BOOL isInstagramOpen;
}

@property (strong, nonatomic) NSMutableArray *arryOfFBNewsFeed;
@property (strong, nonatomic) NSMutableArray *arryOfTwittes;
@property (strong, nonatomic) NSMutableArray *arryOfAllFeeds;
@property (strong, nonatomic) NSMutableArray *arryOfInstagrame;

@end

@implementation ViewController

BOOL hasTwitter = NO;

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];

    //right button
    UIBarButtonItem *barBtnEdit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:nil];
    self.navigationItem.rightBarButtonItem = barBtnEdit;

    //left button
    UIBarButtonItem *barBtnProfile = [[UIBarButtonItem alloc]initWithCustomView:[self addUserImgAtRight]];
    self.navigationItem.leftBarButtonItem = barBtnProfile;

    self.arryOfFBNewsFeed = [[NSMutableArray alloc]init];
    self.arryOfTwittes = [[NSMutableArray alloc]init];
    self.arryOfInstagrame = [[NSMutableArray alloc]init];
    self.arryOfAllFeeds = [[NSMutableArray alloc]init];

    [self makeCustomViewForNavigationTitle];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appIsInForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    self.arryOfFBNewsFeed = nil;
	[self.tbleVwPostList reloadData];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self appIsInForeground:nil];
}

- (void)viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)appIsInForeground:(id)sender {

    if (self.arryOfAllFeeds.count == 0) {

        [self.view addSubview:sharedAppDelegate.spinner];
        [self.view bringSubviewToFront:sharedAppDelegate.spinner];
        [sharedAppDelegate.spinner show:YES];
    }

    if (isInstagramOpen == YES) { //if it only get data from instagram

        isInstagramOpen = NO;
        return;
    }

    [self showFacebookPost];
}

#pragma mark - Check session of facebook

- (void) showFacebookPost {

    if (![SLComposeViewController
          isAvailableForServiceType:SLServiceTypeFacebook]) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [sharedAppDelegate.spinner hide:YES];
            [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
            [self.arryOfAllFeeds removeAllObjects];

            [self getTweetFromTwitter];// getInstagrameIntegration];
        });
        return;
    } else {

        [FBSettings setDefaultAppID:@"357620804394305"];
        [FBAppEvents activateApp];

        if (FBSession.activeSession.state == FBSessionStateOpen ||
		    FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
			sharedAppDelegate.fbSession = FBSession.activeSession;
			sharedAppDelegate.hasFacebook = YES;
		}
    }
	[self updatePosts];
}

#pragma mark - Login with facebook

- (void)loginFacebook {

    [FBSession openActiveSessionWithReadPermissions:@[
                                                      @"basic_info",
                                                      @"read_stream", @"email"
                                                      ]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      if (error) {

                                          sharedAppDelegate.hasFacebook = NO;
                                          [sharedAppDelegate.spinner hide:YES];
                                      } else {

                                          sharedAppDelegate.fbSession = session;
                                          sharedAppDelegate.hasFacebook = YES;
                                          [self updatePosts];
                                      }
                                  }];
}

#pragma mark - get posts

- (void)updatePosts {

	[self getNewsfeedOfFB];
}

#pragma mark - Get news feed of facebook

- (void)getNewsfeedOfFB {

    if (! sharedAppDelegate.hasFacebook) {
		[self loginFacebook];
		return;
	}

    [self.arryOfAllFeeds removeAllObjects];

	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"access_token"] = sharedAppDelegate.fbSession.accessTokenData;

	FBRequest *request = [FBRequest requestForGraphPath:@"me/home"];
    [FBSession setActiveSession:sharedAppDelegate.fbSession];

	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@", [error description]);
		if (error) {
            [Constant showAlert:ERROR_CONNECTING forMessage:@"Feeds is not comming"];
            [sharedAppDelegate.spinner hide:YES];
            [self getTweetFromTwitter];
		} else {
			NSArray *arryPost = [result objectForKey:@"data"];

            [self convertDataOfFBIntoModel:arryPost];
		}
	}];
}

#pragma mark - Convert array of FB into model class

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    if (arryPost.count != 0) {

        [self.arryOfAllFeeds removeObject:self.arryOfFBNewsFeed];
        [self.arryOfFBNewsFeed removeAllObjects];
    }
    for (NSDictionary *dictData in arryPost) {

        NSDictionary *fromUser = [dictData objectForKey:@"from"];

        UserInfo *userInfo =[[UserInfo alloc]init];
        userInfo.strUserName = [fromUser valueForKey:@"name"];
        userInfo.fromId = [fromUser valueForKey:@"id"];
        userInfo.strUserPost = [dictData valueForKey:@"message"];
        userInfo.strUserSocialType = @"Facebook";
        userInfo.type = [dictData objectForKey:@"type"];
        userInfo.struserTime = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
        [self.arryOfFBNewsFeed addObject:userInfo];
        userInfo.strPostImg = [dictData valueForKey:@"picture"];

        NSLog(@"%@", userInfo.struserTime);
    }
    [self.arryOfAllFeeds addObjectsFromArray:self.arryOfFBNewsFeed];
    [self getTweetFromTwitter];// getInstagrameIntegration];
}

#pragma mark - View to add image at left side

- (UIImageView *)addUserImgAtRight {

        //add mask image
    UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed: @"user-selected.png"] withMask:[UIImage imageNamed:@"list-mask.png"]];
    UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
    imgVwProile.frame = CGRectMake(0, 0, 35, 35);
    return imgVwProile;
}

#pragma mark - Get Tweets from twitter

- (void)getTweetFromTwitter {

    if (![SLComposeViewController
          isAvailableForServiceType:SLServiceTypeTwitter]) {

        NSLog(@"%@", self.tabBarController.selectedViewController);

        if (self.tabBarController.selectedViewController == self.navigationController) { //if this view controller is currently tapped
            dispatch_async(dispatch_get_main_queue(), ^{
                [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
            });
        }
        [self.arryOfAllFeeds removeObject:self.arryOfTwittes];
        [self getInstagrameIntegration];
        [sharedAppDelegate.spinner hide:YES];
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
                   ACAccount *twitterAccount = [arrayOfAccounts lastObject];

                   NSURL *requestURL = [NSURL URLWithString:TWITTER_TIMELINE_URL];
                   SLRequest *timelineRequest = [SLRequest
                                             requestForServiceType:SLServiceTypeTwitter
                                             requestMethod:SLRequestMethodGET
                                             URL:requestURL parameters:nil];

                   timelineRequest.account = twitterAccount;

                   [timelineRequest performRequestWithHandler:
                    ^(NSData *responseData, NSHTTPURLResponse
                      *urlResponse, NSError *error)
                    {
                      NSLog(@"%@ !#" , [error description]);
                      NSArray *arryTwitte = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];

                      if (arryTwitte.count != 0) {
                          dispatch_async(dispatch_get_main_queue(), ^{

                              [self convertDataOfTwitterIntoModel: arryTwitte];//convert into model class
                          });
                      } else {
                          dispatch_async(dispatch_get_main_queue(), ^{

                              [sharedAppDelegate.spinner hide:YES];
                              [Constant showAlert:@"Message" forMessage:@"No Tweet in your account."];
                          });
                           [self getInstagrameIntegration];
                      }
                    }];
                 }
           } else {
                   // Handle failure to get account access
           }
         }];
    }
}

#pragma mark - Convert data of twitter in to model class

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    if (arryPost.count != 0) {

        [self.arryOfAllFeeds removeObject:self.arryOfTwittes];
        [self.arryOfTwittes removeAllObjects];
    }
    for (NSDictionary *dictData in arryPost) {

        NSLog(@"**%@", dictData);

        NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];

        UserInfo *userInfo =[[UserInfo alloc]init];
        userInfo.strUserName = [postUserDetailDict valueForKey:@"name"];
        userInfo.fromId = [postUserDetailDict valueForKey:@"id"];
        userInfo.strUserImg = [postUserDetailDict valueForKey:@"profile_image_url"];

        NSArray *arryMedia = [[dictData objectForKey:@"extended_entities"] objectForKey:@"media"];

        if (arryMedia.count>0) {
            userInfo.strPostImg = [[arryMedia objectAtIndex:0] valueForKey:@"media_url"];
        }
        userInfo.strUserPost = [dictData valueForKey:@"text"];
        userInfo.strUserSocialType = @"Twitter";
        userInfo.type = [dictData objectForKey:@"type"];
        NSString *strDate = [self dateOfTwitter:[dictData objectForKey:@"created_at"]];
        userInfo.struserTime = [Constant convertDateOFTweeter:strDate];
        [self.arryOfTwittes addObject:userInfo];

        NSLog(@"%@", self.arryOfTwittes);
    }
    [self.arryOfAllFeeds addObjectsFromArray:self.arryOfTwittes];
    [self getInstagrameIntegration];
}

#pragma mark - Convert date of twitter

- (NSString *)dateOfTwitter:(NSString *)createdDate {

    NSString *strDateInDatabaseFormate;

    NSString *strYear = [createdDate substringWithRange:NSMakeRange(createdDate.length-4, 4)];
    NSString *strMonth = [createdDate substringWithRange:NSMakeRange(4, 3)];
    NSString *strDate = [createdDate substringWithRange:NSMakeRange(8, 2)];

    NSString *strTime = [createdDate substringWithRange:NSMakeRange(11, 8)];//14

    NSString *finalDate = [NSString stringWithFormat:@"%@ %@ %@", strDate, strMonth, strYear];

    strDateInDatabaseFormate = [NSString stringWithFormat:@"%@ %@", finalDate, strTime];

    return strDateInDatabaseFormate;
}

#pragma mark - Sort array of news feed

- (void)shortArryOfAllFeeds {

    [sharedAppDelegate.spinner hide:YES];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"struserTime" ascending:NO];//give key name
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSArray *sortedArray = [self.arryOfAllFeeds sortedArrayUsingDescriptors:sortDescriptors];
    [self.arryOfAllFeeds removeAllObjects];
    self.arryOfAllFeeds = [sortedArray mutableCopy];

    for (int i=0; i<self.arryOfAllFeeds.count; i++) {

        UserInfo *info = [self.arryOfAllFeeds objectAtIndex:i];
        NSLog(@"***%@***", info.struserTime);
    }

    [self.tbleVwPostList reloadData];
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@" ** count %icount ", self.arryOfAllFeeds.count);
    return [self.arryOfAllFeeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"cellIdentifier";
    CustomTableCell *cell;

    cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        NSArray *arryObjects;
        if (cell == nil) {

            arryObjects = [[NSBundle mainBundle]loadNibNamed:@"CustomTableCell" owner:nil options:nil];
            cell = [arryObjects objectAtIndex:0];
        }

    [cell setValueInSocialTableViewCustomCell: [self.arryOfAllFeeds objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryOfAllFeeds objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                       context:nil];

    if (objUserInfo.strPostImg.length != 0) {
        return(rect.size.height + 160);
    }
    return (rect.size.height + 60);//183 is height of other fixed content
}

#pragma mark - Custom view over navigation bar

- (void)makeCustomViewForNavigationTitle {

        // UIView *vwTitle = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 170)/2, 0, 170, 44)];
        // vwTitle.backgroundColor = [UIColor blackColor];
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 160)/2, 10, 160, 21)];
    lblName.text = @"Timeline";
    lblName.font = [UIFont boldSystemFontOfSize:17];
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.textColor = [UIColor blackColor];

        //[vwTitle addSubview:vwTitle];

    [self.navigationController.navigationBar addSubview:lblName];
    [self.navigationController.navigationBar bringSubviewToFront:lblName];
}

#pragma mark - Integrate instagrame

- (void)getInstagrameIntegration {

    // here i can set accessToken received on previous login
    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;
    [sharedAppDelegate.spinner hide:YES];
    if ([sharedAppDelegate.instagram isSessionValid]) {

        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/feed", @"method", nil]; //fetch feed
        [sharedAppDelegate.instagram requestWithParams:params
                                        delegate:self];
    } else {

        if (self.tabBarController.selectedViewController == self.navigationController) {

            UIAlertView *alertVw = [[UIAlertView alloc]initWithTitle:@"Instagrame" message:@"Are You want to open Instagrame through safari." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
            [alertVw show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if ([alertView.title isEqualToString:@"Facebook"]) {

    }
    if (buttonIndex == 0) {

        [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
        isInstagramOpen = YES;
    } else {

        [self shortArryOfAllFeeds];
    }
}

- (void)login {

    [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

#pragma - IGSessionDelegate

- (void)igDidLogin {

    NSLog(@"Instagram did login");
        // here i can store accessToken
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
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    isInstagramOpen = NO;
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

    NSLog(@"Instagram did load: %@", result);
    NSArray *arry = [result objectForKey:@"data"];

    [self convertDataOfInstagramIntoModelClass:arry];
}

#pragma mark - Convert data of instagrame in to model class

- (void)convertDataOfInstagramIntoModelClass:(NSArray *)arryOfInstagrame {

    if (arryOfInstagrame.count != 0) {
        [self.arryOfInstagrame removeAllObjects];
    }
    for (NSDictionary *dictData in arryOfInstagrame) {

        NSLog(@" instagrame %@", dictData);
        UserInfo *userInfo =[[UserInfo alloc]init];

        NSDictionary *postUserDetailDict = [dictData objectForKey:@"caption"];
        NSLog(@" $$ %@", postUserDetailDict);

        NSDictionary *dictUserInfo = [postUserDetailDict objectForKey:@"from"];
        userInfo.strUserName = [dictUserInfo valueForKey:@"username"];
        userInfo.fromId = [dictUserInfo valueForKey:@"id"];
        sharedAppDelegate.InstagramId = userInfo.fromId;
        userInfo.strUserImg = [dictUserInfo valueForKey:@"profile_picture"];

        userInfo.strUserPost = [postUserDetailDict valueForKey:@"text"];
        NSString *strDate = [postUserDetailDict objectForKey:@"created_time"];

        NSTimeInterval interval = strDate.doubleValue;
        NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970: interval];
        NSLog(@"Date = %@", convertedDate);
        userInfo.struserTime = [Constant convertDateOFInstagram:convertedDate];

        NSDictionary *dictImage = [dictData objectForKey:@"images"];
        userInfo.strPostImg = [[dictImage valueForKey:@"low_resolution"]objectForKey:@"url"];

        userInfo.type = [dictData objectForKey:@"type"];
        userInfo.strUserSocialType = @"Instagram";
        [self.arryOfInstagrame addObject:userInfo];

        NSLog(@"%@", self.arryOfInstagrame);
    }
    [self.arryOfAllFeeds addObjectsFromArray:self.arryOfInstagrame];
    [self shortArryOfAllFeeds];
}

#pragma mrk - Demo data

- (void)demoData {

    UserInfo *userInfo1 = [[UserInfo alloc]init];
    userInfo1.strUserName = @"Dennie Ritches";
    userInfo1.strUserPost = @"Twitter post. Apple has launch iPhone 6. it is on high demand in All over word.";
    userInfo1.struserTime = @"2m";
    userInfo1.strUserSocialType = @"Twitter";
    userInfo1.strUserImg = @"user-selected.png";
        // [self.arryOfFBNewsFeed addObject:userInfo1];

    UserInfo *userInfo2 = [[UserInfo alloc]init];
    userInfo2.strUserName = @"Albert Jeck";
    userInfo2.strUserPost = @"Instagrame post. You look social app. Spend more time to read books.";
    userInfo2.struserTime = @"1h";
    userInfo2.strUserSocialType = @"Instagrame";
    userInfo2.strUserImg = @"user-selected.png";
        // [self.arryOfFBNewsFeed addObject:userInfo2];

    UserInfo *userInfo3 = [[UserInfo alloc]init];
    userInfo3.strUserName = @"Albert Jeck";
    userInfo3.strUserPost = @"Instagrame post. You look social app. Spend more time to read books.";
    userInfo3.struserTime = @"1h";
    userInfo3.strUserSocialType = @"Instagrame";
    userInfo3.strUserImg = @"user-selected.png";
        //[self.arryOfFBNewsFeed addObject:userInfo3];
}

@end

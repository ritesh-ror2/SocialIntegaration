
    //
//  ViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ViewController.h"
#import "UserInfo.h"
#import "Constant.h"
#import "FeedPagesViewController.h"
#import "AppDelegate.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import "CommentViewController.h"
#import "ShowOtherUserProfileViewController.h"
#import "Reachability.h"
#import "ShareCommentAndMessageViewController.h"
#import <Social/Social.h>

NSString *const kSocialServices = @"SocialServices";
NSString *const kFBSetup = @"FBSetup";

@interface ViewController () {

    BOOL isInstagramOpen;

    NSMutableData *fbData;
    NSMutableURLRequest *fbRequest;
    NSURLConnection *connetion;
    BOOL isFirstTimeUpload;
    BOOL isFirstTimeDownloadTwitter;
}

@property (nonatomic)BOOL noMoreResultsAvail;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;
@property (nonatomic, strong) NSMutableArray *arryCellTappedTwices;
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

    //left button
    UIBarButtonItem *barBtnProfile = [[UIBarButtonItem alloc]initWithCustomView:[self addUserImgAtRight]];
   self.navItem.leftBarButtonItem = barBtnProfile;

    self.navController.navigationBar.translucent = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(appIsInForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

        // [self appIsInForeground:nil];

    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];
    self.arryCellTappedTwices = [[NSMutableArray alloc]init];

    if (IS_IOS7) {
        [self.tbleVwPostList setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.navigationController.navigationBar.translucent = NO;

    [self.arrySelectedIndex removeAllObjects];
    [self.arrySelectedIndex removeAllObjects];
    [self.tbleVwPostList reloadData];

    isFirstTimeUpload = YES;
    isFirstTimeDownloadTwitter = YES;

//    if (sharedAppDelegate.arryOfAllFeeds.count != 0){
//        [self shortArryOfAllFeeds];
//    }
    [self appIsInForeground:nil];
    self.navController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    self.navItem.title = @"Timeline";
    if (sharedAppDelegate.isFirstTimeLaunch == YES) {

        self.tbleVwPostList.alpha = 0.0;
        sharedAppDelegate.isFirstTimeLaunch = NO;
        [self performSelector:@selector(animationOfTimeline) withObject:nil afterDelay:0.0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (IBAction)composeMessage:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareCommentAndMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"sharecomment"];
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (UIImageView *)addUserImgAtRight {

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

- (void)animationOfTimeline {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:3.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.tbleVwPostList setHidden:NO];
    [self.tbleVwPostList setAlpha:1];

    [UIView commitAnimations];

 }

- (void)appIsInForeground:(id)sender {

    NSLog(@"%i %i, %i ", sharedAppDelegate.arryOfAllFeeds.count , sharedAppDelegate.arryOfInstagrame.count, sharedAppDelegate.arryOfFBNewsFeed.count);
    if (sharedAppDelegate.arryOfAllFeeds.count == 0) {

        [self.view addSubview:sharedAppDelegate.spinner];
        [self.view bringSubviewToFront:sharedAppDelegate.spinner];
        [sharedAppDelegate.spinner show:YES];
    }

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;

    if (isInstagramOpen == YES) { //if it only get data from instagram
        isInstagramOpen = NO;
    }

        // [self getInstagrameIntegration];
    [self showFacebookPost];
}

#pragma mark - Check session of facebook

- (void)showFacebookPost {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

        dispatch_async(dispatch_get_main_queue(), ^{

                // [sharedAppDelegate.spinner hide:YES];
            [sharedAppDelegate.arryOfFBNewsFeed removeAllObjects];

            [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB ];

            [self getTweetFromTwitter];// getInstagrameIntegration];
        });
        return;
    } else {

        [FBSettings setDefaultAppID:@"1544707672409931"];
        [FBAppEvents activateApp];

        if (FBSession.activeSession.state == FBSessionStateOpen ||
		    FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
			sharedAppDelegate.fbSession = FBSession.activeSession;
			sharedAppDelegate.hasFacebook = YES;
		}
    }
	[self updatePosts];
}

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    if ([userInfo.strUserSocialType isEqualToString:@"Facebook"]) {
        NSString *strUserId = [NSString stringWithFormat:@"/%@",userInfo.fromId];
        /* make the API call */
        [FBRequestConnection startWithGraphPath:strUserId
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  if (error) {

                                  } else {

                                      NSDictionary *dictProfile = (NSDictionary *)result;

                                      UserInfo *otherUserInfo = [[UserInfo alloc]init];
                                      otherUserInfo.strUserName = [dictProfile valueForKey:@"name"];
                                      otherUserInfo.fromId  = [dictProfile valueForKey:@"id"];
                                      otherUserInfo.strUserSocialType = @"Facebook";
                                      UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                      ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
                                      vwController.userInfo = otherUserInfo;
                                      [self.navigationController pushViewController:vwController animated:YES];
                                  }
                              }];
    } if ([userInfo.strUserSocialType isEqualToString:@"Twitter"])  {

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
        vwController.userInfo = userInfo;
        [self.navigationController pushViewController:vwController animated:YES];
    }
}

#pragma mark - Login with facebook

- (void)loginFacebook {

   /* [FBSession openActiveSessionWithReadPermissions:@[
                                                      @"basic_info",
                                                      @"read_stream", @"email", @"user_friends", @"user_likes"
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
                                  }];*/

    [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info",  @"read_stream", @"email", @"user_friends", @"user_likes"]  allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
	                                                  FBSessionState state,
	                                                  NSError *error) {
                                      if (error) {

                                          sharedAppDelegate.hasFacebook = NO;
                                          [sharedAppDelegate.spinner hide:YES];
                                      } else {

                                          sharedAppDelegate.fbSession = session;
                                          sharedAppDelegate.hasFacebook = YES;

                                          [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISFBLOGIN];
                                          [[NSUserDefaults standardUserDefaults]synchronize];

                                          [self getNewsfeedOfFB];
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

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	parameters[@"access_token"] = sharedAppDelegate.fbSession.accessTokenData;

	FBRequest *request = [FBRequest requestForGraphPath:@"me/home"];
    [FBSession setActiveSession:sharedAppDelegate.fbSession];

	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@", [error description]);
		if (error) {
            [Constant showAlert:ERROR_CONNECTING forMessage:@"Feeds is not comming"];
                // [sharedAppDelegate.spinner hide:YES];
            [self getTweetFromTwitter];
		} else {
			NSArray *arryPost = [result objectForKey:@"data"];
            sharedAppDelegate.nextFbUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];

            [self convertDataOfFBIntoModel:arryPost];
		}
	}];
}

#pragma mark - Convert array of FB into model class

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    if (isFirstTimeUpload == YES) {
        [sharedAppDelegate.arryOfFBNewsFeed removeAllObjects];
    }
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *fromUser = [dictData objectForKey:@"from"];

            userInfo.strUserName = [fromUser valueForKey:@"name"];
            userInfo.fromId = [fromUser valueForKey:@"id"];
            userInfo.strUserPost = [dictData valueForKey:@"message"];
            userInfo.strUserSocialType = @"Facebook";
            userInfo.fbLike = [[dictData valueForKey:@"user_likes"] boolValue];
            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.struserTime = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
            userInfo.strPostImg = [dictData valueForKey:@"picture"];
            userInfo.postId = [dictData valueForKey:@"id"];
            NSLog(@"*** %@", [dictData objectForKey:@"type"]);
            if (![[dictData objectForKey:@"type"] isEqualToString:@"video"] && ![[dictData objectForKey:@"type"] isEqualToString:@"photo"]) {
                userInfo.objectIdFB = [dictData valueForKey:@"id"];
             } else {
                userInfo.objectIdFB = [dictData valueForKey:@"object_id"];
             }

            NSLog(@"** %@", userInfo.type);
            userInfo.videoUrl = [dictData valueForKey:@"source"];
            [sharedAppDelegate.arryOfFBNewsFeed addObject:userInfo];

        }
    }
    if (isFirstTimeUpload == YES) {
        [self getTweetFromTwitter];
    } else {
        [self shortArryOfAllFeeds];
    }
}

#pragma mark - Get Tweets from twitter

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
                    [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
                });
            }
        }

        [sharedAppDelegate.arryOfTwittes removeAllObjects];
        NSLog(@" ** %i", sharedAppDelegate.arryOfAllFeeds.count);
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
                   sharedAppDelegate.twitterAccount = [arrayOfAccounts lastObject];

                       //TWITTER_TIMELINE_URL
                       // NSDictionary* params = @{@"count": @"50"};

                   NSURL *requestURL = [NSURL URLWithString:TWITTER_TIMELINE_URL];
                   SLRequest *timelineRequest = [SLRequest
                                                 requestForServiceType:SLServiceTypeTwitter
                                                 requestMethod:SLRequestMethodGET
                                                 URL:requestURL parameters:nil];

                   timelineRequest.account = sharedAppDelegate.twitterAccount;

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

- (void)paggingInTwitter {

        //The max_id = top of tweets id list . since_id = bottom of tweets id list .
        //TWITTER_TIMELINE_URL since_id=24012619984051000&max_id=250126199840518145&result_type=recent&count=10

    UserInfo *userInfo = [sharedAppDelegate.arryOfTwittes objectAtIndex:sharedAppDelegate.arryOfTwittes.count - 1];
    int max_Id = userInfo.statusId.intValue;

    UserInfo *userInfoSince = [sharedAppDelegate.arryOfTwittes objectAtIndex:0];
    int since_Id = userInfoSince.statusId.intValue;

    NSDictionary* params = @{@"since_id":[NSNumber numberWithInt:since_Id], @"max_id":[NSNumber numberWithInt:max_Id], @"count":@"30"};

    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:params];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error)
     {
       NSLog(@"%@ !#" , [error description]);
       id result = [NSJSONSerialization
                    JSONObjectWithData:responseData
                    options:NSJSONReadingMutableLeaves
                    error:&error];

       if (![result isKindOfClass:[NSDictionary class]]) {

           isFirstTimeDownloadTwitter = NO;
           NSArray *arryTwitte = (NSArray *)result;
           [self convertDataOfTwitterIntoModel:arryTwitte];
       } else {
           NSLog(@"error %@", result);
       }
     }];
}


#pragma mark - Convert data of twitter in to model class

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    if (isFirstTimeDownloadTwitter == YES) {
        [sharedAppDelegate.arryOfTwittes removeAllObjects];
    }
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            NSLog(@"**%@", dictData); //14055301;

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
            userInfo.statusId = [dictData valueForKey:@"id"];
            userInfo.favourated = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"favorited"] integerValue]];
            userInfo.screenName = [postUserDetailDict valueForKey:@"screen_name"];
            userInfo.retweeted = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"retweeted"] integerValue]];
            userInfo.retweetCount = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"retweet_count"] integerValue]];
            userInfo.favourateCount = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"favorite_count"] integerValue]];
            userInfo.isFollowing = [[postUserDetailDict valueForKey:@"following"]boolValue];
            userInfo.dicOthertUser = postUserDetailDict;
            [sharedAppDelegate.arryOfTwittes addObject:userInfo];
        }
    }

    if (isFirstTimeDownloadTwitter == YES) {
        [self getInstagrameIntegration];
    } else {
            //[self shortArryOfAllFeeds];
    }
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

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@" ** count %icount ", sharedAppDelegate.arryOfAllFeeds.count);
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

    if(indexPath.row < [sharedAppDelegate.arryOfAllFeeds count]){

        self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfAllFeeds objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:NO];
    } else {

        if (sharedAppDelegate.arryOfAllFeeds.count != 0) {

            if (self.noMoreResultsAvail == NO) {

            [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:YES];
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
                [self getMoreDataOfFBFeed];

                if (isFirstTimeDownloadTwitter == YES) {
                    [self paggingInTwitter];
                }
            } else {
                self.noMoreResultsAvail = NO;
            }
        }
    }
    NSLog(@"%@",cell.touchCount);
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfAllFeeds.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfAllFeeds count]-1) {
            return 44;
        }
    } else {
        return 0;
    }
    UserInfo *objUserInfo = [sharedAppDelegate.arryOfAllFeeds objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    if (objUserInfo.strPostImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + 197);
            }
        }
    return(rect.size.height + 165);
    }

    for (NSString *index in self.arrySelectedIndex) {

        if (index.integerValue == indexPath.row) {
            return(rect.size.height + 90);
        }
    }
    return (rect.size.height + 58);//183 is height of other fixed content
}

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    
    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    NSLog(@"****%@***", self.arrySelectedIndex);
        //your code here

    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwPostList beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwPostList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwPostList endUpdates];
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

        // CustomTableCell *cell = (CustomTableCell*)[tableView cellForRowAtIndexPath:indexPath];
        // [cell setSelected:YES animated:NO];
    UserInfo *userInfo = [sharedAppDelegate.arryOfAllFeeds objectAtIndex:indexPath.row];
    if ([[self.arryCellTappedTwices objectAtIndex:indexPath.row] isEqualToString:@"1"]) {

        [self.arryCellTappedTwices replaceObjectAtIndex:indexPath.row withObject:@"2"];
        [self tappedOnCellToShowActivity:userInfo withCellIndex:indexPath.row withSelectedPrNot:YES];

    } else {
        [self.arryCellTappedTwices replaceObjectAtIndex:indexPath.row withObject:@"1"];
        [self didSelectRowWithObject:userInfo withFBProfileImg:nil];
    }
}*/
#pragma mark - Integrate instagrame

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
        // here i can set accessToken received on previous login
    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;

    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    if (isInstagramUserLogin == NO) {

        [sharedAppDelegate.spinner hide:YES];
        NSArray *arryVwController = self.navController.viewControllers;
        UIViewController *vwController = [arryVwController lastObject];
        
        if ([vwController isKindOfClass:[FeedPagesViewController class]]) { //if this view controller is currently tapped
            if (self.tabBarController.selectedViewController == self.navigationController) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_INSTAGRAM];
                });
            }
        }
            [sharedAppDelegate.arryOfInstagrame removeAllObjects];
            [self shortArryOfAllFeeds];

    } else {

            ///v1/users/3/media/recent/?access_token=ACCESS-TOKEN
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

- (void)login {

    [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
}

#pragma - IGSessionDelegate

- (void)igDidLogin {

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

         NSLog(@"Instagram did load: %@", result);
    NSArray *arry = [result objectForKey:@"data"];
    [self convertDataOfInstagramIntoModelClass:arry];
}

#pragma mark - Convert data of instagrame in to model class

- (void)convertDataOfInstagramIntoModelClass:(NSArray *)arryOfInstagrame {

    if (isFirstTimeUpload == YES) {
        [sharedAppDelegate.arryOfInstagrame removeAllObjects];
    }

    @autoreleasepool {

        for (NSDictionary *dictData in arryOfInstagrame) {

            NSLog(@" instagrame %@", dictData);
            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"caption"];

            NSDictionary *dictUserInfo = [postUserDetailDict objectForKey:@"from"];
            userInfo.strUserName = [dictUserInfo valueForKey:@"username"];
            userInfo.fromId = [dictUserInfo valueForKey:@"id"];
            sharedAppDelegate.InstagramId = userInfo.fromId;
            userInfo.strUserImg = [dictUserInfo valueForKey:@"profile_picture"];

            userInfo.strUserPost = [postUserDetailDict valueForKey:@"text"];
            NSString *strDate = [postUserDetailDict objectForKey:@"created_time"];

            NSTimeInterval interval = strDate.doubleValue;
            NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970: interval];
            userInfo.struserTime = [Constant convertDateOFInstagram:convertedDate];

            NSDictionary *dictImage = [dictData objectForKey:@"images"];
            userInfo.strPostImg = [[dictImage valueForKey:@"low_resolution"]objectForKey:@"url"];

            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.strUserSocialType = @"Instagram";
            userInfo.statusId = [dictData objectForKey:@"id"];

            [sharedAppDelegate.arryOfInstagrame addObject:userInfo];

            NSLog(@"%@", sharedAppDelegate.arryOfInstagrame);
        }
    }
    [self shortArryOfAllFeeds];
}

#pragma mark - Sort array of news feed

- (void)shortArryOfAllFeeds {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;


    [sharedAppDelegate.arryOfAllFeeds removeAllObjects]; //first remove all object
    [self.arryTappedCell removeAllObjects];
    
    [sharedAppDelegate.arryOfAllFeeds addObjectsFromArray:sharedAppDelegate.arryOfFBNewsFeed];
    [sharedAppDelegate.arryOfAllFeeds addObjectsFromArray:sharedAppDelegate.arryOfTwittes];
    [sharedAppDelegate.arryOfAllFeeds addObjectsFromArray:sharedAppDelegate.arryOfInstagrame];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"struserTime" ascending:NO];//give key name
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSArray *sortedArray = [sharedAppDelegate.arryOfAllFeeds sortedArrayUsingDescriptors:sortDescriptors];
    [sharedAppDelegate.arryOfAllFeeds removeAllObjects];
    sharedAppDelegate.arryOfAllFeeds = [sortedArray mutableCopy];

    for (NSString *cellSelected in sharedAppDelegate.arryOfAllFeeds) {
        NSLog(@"%@", cellSelected);
        [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        [self.arryCellTappedTwices addObject:@"1"];
    }

    [sharedAppDelegate.spinner hide:YES];
    [self.tbleVwPostList reloadData];
}

- (void)getMoreDataOfFBFeed {

        //Get more data of feed
    isFirstTimeUpload = NO;

    NSURL *fbUrl = [NSURL URLWithString:sharedAppDelegate.nextFbUrl];
    fbRequest = [[NSMutableURLRequest alloc]initWithURL:fbUrl];
    connetion = [[NSURLConnection alloc]initWithRequest:fbRequest delegate:self];
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
    NSLog(@"%@", result);
    sharedAppDelegate.nextFbUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];
    [self convertDataOfFBIntoModel:[result objectForKey:@"data"]];
}

@end

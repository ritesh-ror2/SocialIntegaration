//
//  UserNotificationViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "UserNotificationViewController.h"
#import "Constant.h"
#import "UserNotification.h"
#import "UserNotificationCustomCell.h"
#import "HYCircleLoadingView.h"
#import "Reachability.h"
#import "ShowOtherUserProfileViewController.h"
#import <Social/Social.h>

@interface UserNotificationViewController () <UserNotificationDelegate> {

    BOOL hasFacebook;
}

@property (nonatomic) BOOL isLoadingShow;
@property (nonatomic, strong) HYCircleLoadingView *loadingView;
@property (nonatomic, strong) NSMutableArray *arryNotifi;
@property (nonatomic, strong) NSMutableArray *arryNotifiFB;
@property (nonatomic, strong) NSMutableArray *arryNotifiTwitter;

@end

@implementation UserNotificationViewController

#pragma mark - View life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationItem.title = @"Notification";
    self.navigationController.navigationBarHidden = NO;

    self.arryNotifi = [[NSMutableArray alloc]init];
    self.arryNotifiFB = [[NSMutableArray alloc]init];
    self.arryNotifiTwitter = [[NSMutableArray alloc]init];

    self.navigationItem.hidesBackButton = YES;

    self.loadingView = [[HYCircleLoadingView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, (self.view.frame.size.height - 70)/2, 70, 70)];
    [self.view addSubview:self.loadingView];
    [self.view bringSubviewToFront:self.loadingView];
    self.loadingView.hidden = YES;

    tbleViewNotification.hidden = YES;
    tbleViewNotification.alpha = 0.0;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {

    self.navigationItem.title = @"Notification";
    self.navigationController.navigationBarHidden = NO;

    [super viewDidAppear:animated];

    if (self.isLoadingShow == NO) {
        [self showAnimationView];
    }

    [Constant showNetworkIndicator];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

            //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
        [self.arryNotifiFB removeAllObjects];
        [self twitterNotification];
        return;
    }

    [self getFBUserNotification];
}

- (void)showAnimationView {


    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [Constant hideNetworkIndicator];
        [self.loadingView stopAnimation];
        [self.loadingView setHidden:YES];
        return;
    }
    
    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if(isFbLogin == YES || isTwitter == YES) {

        self.isLoadingShow = YES;
        self.loadingView.hidden = NO;
        [self.loadingView startAnimation];
    }
}

#pragma mark - Get Twitter Notification
/**************************************************************************************************
 Function to get Twitter notification
 **************************************************************************************************/

- (void)twitterNotification {

    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitter == NO) {

        [self shortArryOfAllFeeds];
        [self.arryNotifiTwitter removeAllObjects];
        [Constant hideNetworkIndicator];
            //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        return;
    }

    NSURL *requestURL = [NSURL URLWithString:TWITTER_MENTION_URL];//@"https://api.twitter.com/1.1/statuses/mentions_timeline.json"];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:nil];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error) {

    if (!error) {

        NSLog(@"%@ !#" , [error description]);
        id dataTwitte = [NSJSONSerialization
                         JSONObjectWithData:responseData
                         options:NSJSONReadingMutableLeaves
                         error:&error];

        if ([dataTwitte isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictData = (NSDictionary *)dataTwitte;
            if ([[dictData objectForKey:@"errors"]count] != 0) {

                NSLog(@"%@", [dictData objectForKey:@"errors"]);
                [self shortArryOfAllFeeds];
                return ;
            }
        } else {
            NSArray *arryData1 = (NSArray *)dataTwitte;

            if (arryData1.count != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"success");
                    [self convertDataOfTwitterNotification:arryData1];
                });
            } else {
                [self shortArryOfAllFeeds];
                dispatch_async(dispatch_get_main_queue(), ^{

                    [Constant hideNetworkIndicator];
                        // [Constant showAlert:@"Message" forMessage:@"No notification in Twitter account."];
                });
            }
        }
    }
    }];
}

#pragma mark - Convert data of twitter in to model class
/**************************************************************************************************
 Function to convert data of twitter in to model class
 **************************************************************************************************/

- (void)convertDataOfTwitterNotification:(NSArray*)arryNotification {

    [self.arryNotifiTwitter removeAllObjects];

    for (NSDictionary *dictData in arryNotification) {

        UserNotification *userNotif = [[UserNotification alloc]init];

        NSDictionary *dictUser = [dictData objectForKey:@"user"];
        NSString *strTitle = [NSString stringWithFormat:@"%@, %@", [dictUser objectForKey:@"name"] ,[dictData objectForKey:@"text"]];
        userNotif.title = strTitle;
        userNotif.notif_id = [dictData objectForKey:@"id"];
        userNotif.name = [dictUser objectForKey:@"name"];
        NSString *strDate = [Constant convertDateOfTwitterInDatabaseFormate:[dictData objectForKey:@"created_at"]];
        userNotif.time = [Constant convertDateOFTwitter:strDate];
        userNotif.notifType = @"Twitter";
        userNotif.userImg = [dictUser objectForKey:@"profile_image_url"];

        userNotif.dicOthertUser = dictUser;

        [self.arryNotifiTwitter addObject:userNotif];
    }

    [self shortArryOfAllFeeds];
}

#pragma mark - Fb user notification
/**************************************************************************************************
 Function to get of Fb notification
 **************************************************************************************************/

- (void)getFBUserNotification {

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"manage_notifications"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;

        [FBRequestConnection startWithGraphPath:@"/me/notifications"
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  if (error) {
                                      [self twitterNotification]; //in case of error
                                  } else {

                                      NSLog(@"success");
                                      [self convertDataOfFbNotification:[result valueForKey:@"data"]];
                                  }
                              }];
    }];
}

#pragma mark - Convert Fb data
/**************************************************************************************************
 Function to convert data of Fb in to model class
 **************************************************************************************************/

- (void)convertDataOfFbNotification:(NSArray*)arryNotification {

    [self.arryNotifiFB removeAllObjects];

    for (NSDictionary *dictData in arryNotification) {

        if ([[dictData valueForKey:@"unread"]integerValue] == 1) {

            UserNotification *userNotif = [[UserNotification alloc]init];
            userNotif.title = [dictData objectForKey:@"title"];
            userNotif.notif_id = [dictData objectForKey:@"id"];
            userNotif.fromId = [[dictData objectForKey:@"from"]objectForKey:@"id"];
            userNotif.name = [[dictData objectForKey:@"from"]objectForKey:@"name"];
            userNotif.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
            userNotif.notifType = @"Facebook";

            [self.arryNotifiFB addObject:userNotif];
        }
    }
    [self twitterNotification];
}

#pragma mark - Short array of notification
/**************************************************************************************************
 Function to short array of notification
 **************************************************************************************************/

- (void)shortArryOfAllFeeds {

    [self.arryNotifi removeAllObjects]; //first remove all object

    [self.arryNotifi addObjectsFromArray:self.arryNotifiFB];
    [self.arryNotifi addObjectsFromArray:self.arryNotifiTwitter];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];//give key name
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSArray *sortedArray = [self.arryNotifi sortedArrayUsingDescriptors:sortDescriptors];
    [self.arryNotifi removeAllObjects];
    self.arryNotifi = [sortedArray mutableCopy];

    [Constant hideNetworkIndicator];

    [tbleViewNotification reloadData];

    if (self.arryNotifi.count != 0){

        [self showAnimationOfActivity];
        self.loadingView.hidden = YES;
        [self.loadingView stopAnimation];
    }
}

- (void)showAnimationOfActivity {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [tbleViewNotification setHidden:NO];
    [UIView setAnimationDuration:3.0];
    [tbleViewNotification setAlpha:1];
    tbleViewNotification.hidden = NO;
    [UIView commitAnimations];

    self.loadingView.hidden = YES;
    [self.loadingView stopAnimation];
}

#pragma mark - UITable view Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryNotifi count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"UserNotification";
    UserNotificationCustomCell *cell;

    cell = (UserNotificationCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setNotificationIntableView:[self.arryNotifi objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITable view Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {

    UserNotification *userNotify = [self.arryNotifi objectAtIndex:indexPath.row];

    NSString *string = [NSString stringWithFormat:@"%@ on %@", userNotify.title, userNotify.notifType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake([Constant widthOfCommentLblOfTimelineAndProfile], 200)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];
    
    return (rect.size.height+45);
}

#pragma mark - User profile btn tapped
/**************************************************************************************************
 Function to show other user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserNotification*)userNotification {

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
    vwController.userNotification = userNotification;
    [self.navigationController pushViewController:vwController animated:YES];
}

@end

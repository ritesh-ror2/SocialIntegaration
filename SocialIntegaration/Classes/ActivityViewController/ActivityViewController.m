//
//  ActivityViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 24/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityCustomCell.h"
#import "Reachability.h"
#import "UserActivity.h"

#import "UserNotificationCustomCell.h"
#import "UserNotification.h"

@interface ActivityViewController ()

@property (nonatomic, strong) NSMutableArray *arryActivity;
@property (nonatomic, strong) NSMutableArray *arryActivityFB;
@property (nonatomic, strong) NSMutableArray *arryActivityTwitter;
@end

@implementation ActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Activity Log";
    self.arryActivity = [[NSMutableArray alloc]init];

    [self.view addSubview:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];

    [self getProfileOfFB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get FB User Info

- (void)getFBUserInfo {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [sharedAppDelegate.spinner hide:YES];
        return;
    }

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
        [sharedAppDelegate.spinner hide:YES];
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

- (void)loginFacebook {

    [FBSession openActiveSessionWithReadPermissions:@[ @"basic_info",  @"read_stream"]  allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
	                                                  FBSessionState state,
	                                                  NSError *error) {
                                      if (error) {
                                          sharedAppDelegate.hasFacebook = NO;
                                      } else {
                                          sharedAppDelegate.fbSession = session;
                                          sharedAppDelegate.hasFacebook = YES;
                                          [self getProfileOfFB];
                                      }
		                          }];
}

#pragma mark - Get news feed of facebook

- (void)getProfileOfFB {

    [self getUserStatus];
}

#pragma mark-  Get user own post

- (void)getUserStatus {

    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^( FBRequestConnection *connection, id result,  NSError *error) {
                              if (error) {

                                  [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
                              } else {

                                  NSArray *arryPost = [result objectForKey:@"data"];
                                  [self convertDataOfFBIntoModel:arryPost];
                              }
                          }];
}

#pragma mark - Convert array of FB into model class

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    [self.arryActivity removeAllObjects];
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            if ([[dictData valueForKey:@"story"] length] != 0) {

                UserActivity *userInfo =[[UserActivity alloc]init];

                NSDictionary *fromUser = [dictData objectForKey:@"from"];
                userInfo.activityId = [fromUser valueForKey:@"id"];
                userInfo.activityLog = [dictData valueForKey:@"story"];
                userInfo.activitySocialType = @"Facebook";
                userInfo.activityTime = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
                [self.arryActivity addObject:userInfo];
            }
        }
    }
    [sharedAppDelegate.spinner hide:YES];
    
    [self.tbleVwActivity reloadData];
    [sharedAppDelegate.spinner hide:YES];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryActivity count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"activityLog";
    ActivityCustomCell  *cell;

    cell = (ActivityCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setActivityLogIntableView:[self.arryActivity objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {

    UserActivity *userActivity = [self.arryActivity objectAtIndex:indexPath.row];

    NSString *string = [NSString stringWithFormat:@"%@ on %@", userActivity.activityLog, userActivity.activitySocialType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(290, 200)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    return (rect.size.height+10);
}

- (void)showActivityOfFbUser {

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"user_activities"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {

    sharedAppDelegate.fbSession = session;

        //user_activiti
    make the API call
    [FBRequestConnection startWithGraphPath:@"/me/activities"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {

                              } else {
                                  NSArray *arryResult = [result objectForKey:@"data"];
                                  [self showActivityLog:arryResult];
                              }
                          }];
    }];
}*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Activity";
    self.navigationController.navigationBarHidden = NO;

    self.arryActivity = [[NSMutableArray alloc]init];
    self.arryActivityFB = [[NSMutableArray alloc]init];
    self.arryActivityTwitter = [[NSMutableArray alloc]init];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];

    [Constant showNetworkIndicator];

    if (isFbUserLogin == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
        [self twitterNotification];
        return;
    }
    [self getFBUserNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)twitterNotification {

    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitter == NO) {

        [self shortArryOfAllFeeds];
        [Constant hideNetworkIndicator];
        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        return;
    }

    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/mentions_timeline.json"];
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
     }];
}

- (void)convertDataOfTwitterNotification:(NSArray*)arryNotification {

    for (NSDictionary *dictData in arryNotification) {

        UserNotification *userNotif = [[UserNotification alloc]init];

        NSDictionary *dictUser = [dictData objectForKey:@"user"];
        NSString *strTitle = [NSString stringWithFormat:@"%@, %@", [dictUser objectForKey:@"name"] ,[dictData objectForKey:@"text"]];
        userNotif.title = strTitle;
        userNotif.notif_id = [dictData objectForKey:@"id"];
        userNotif.name = [dictUser objectForKey:@"name"];
        NSString *strDate = [self dateOfTwitter:[dictData objectForKey:@"created_at"]];
        userNotif.time = [Constant convertDateOFTweeter:strDate];
        userNotif.notifType = @"Twitter";
        userNotif.userImg = [dictUser objectForKey:@"profile_image_url"];

        [self.arryActivityTwitter addObject:userNotif];
    }

    [self shortArryOfAllFeeds];
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


- (void)sortArrayOfNotification {


}
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

- (void)convertDataOfFbNotification:(NSArray*)arryNotification {

    for (NSDictionary *dictData in arryNotification) {

        if ([[dictData valueForKey:@"unread"]integerValue] == 1) {

            UserNotification *userNotif = [[UserNotification alloc]init];
            userNotif.title = [dictData objectForKey:@"title"];
            userNotif.notif_id = [dictData objectForKey:@"id"];
            userNotif.fromId = [[dictData objectForKey:@"from"]objectForKey:@"id"];
            userNotif.name = [[dictData objectForKey:@"from"]objectForKey:@"name"];
            userNotif.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
            userNotif.notifType = @"Facebook";

            [self.arryActivityFB addObject:userNotif];
        }
    }
    [self twitterNotification];
}

- (void)shortArryOfAllFeeds {

    [self.arryActivity removeAllObjects]; //first remove all object

    [self.arryActivity addObjectsFromArray:self.arryActivityFB];
    [self.arryActivity addObjectsFromArray:self.arryActivityTwitter];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];//give key name
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSArray *sortedArray = [self.arryActivity sortedArrayUsingDescriptors:sortDescriptors];
    [self.arryActivity removeAllObjects];
    self.arryActivity = [sortedArray mutableCopy];

    [Constant hideNetworkIndicator];

    [self.tbleVwActivity reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryActivity count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"UserNotification";
    UserNotificationCustomCell *cell;

    cell = (UserNotificationCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setNotificationIntableView:[self.arryActivity objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {

    UserNotification *userNotify = [self.arryActivity objectAtIndex:indexPath.row];

    NSString *string = [NSString stringWithFormat:@"%@ on %@", userNotify.title, userNotify.notifType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 200)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];
    
    return (rect.size.height+45);
}

@end

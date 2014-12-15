//
//  ActivityViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 24/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ActivityViewController.h"
#import "Reachability.h"
#import "UserActivity.h"

#import "UserNotificationCustomCell.h"
#import "UserNotification.h"
#import "HYCircleLoadingView.h"

@interface ActivityViewController ()

@property (nonatomic) BOOL isLoadingShow;
@property (nonatomic, strong) HYCircleLoadingView *loadingView;
@property (nonatomic, strong) NSMutableArray *arryActivity;
@property (nonatomic, strong) NSMutableArray *arryActivityFB;
@property (nonatomic, strong) NSMutableArray *arryActivityTwitter;
@end

@implementation ActivityViewController

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

    self.navigationItem.title = @"Activity";
    self.navigationController.navigationBarHidden = NO;

    self.arryActivity = [[NSMutableArray alloc]init];
    self.arryActivityFB = [[NSMutableArray alloc]init];
    self.arryActivityTwitter = [[NSMutableArray alloc]init];

    [self.tbleVwActivity setAlpha:0];
    self.tbleVwActivity.hidden = YES;

    self.loadingView = [[HYCircleLoadingView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, (self.view.frame.size.height - 70)/2, 70, 70)];
    [self.view addSubview:self.loadingView];
    [self.view bringSubviewToFront:self.loadingView];
    self.loadingView.hidden = YES;

    [self showAnimationView];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    if (self.isLoadingShow == NO) {
        [self showAnimationView];
    }
    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

            //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
        [self.arryActivityFB removeAllObjects];
        [self twitterNotification];
        return;
    }

    [Constant showNetworkIndicator];
    [self getFBUserNotification];
}

- (void)showAnimationView {

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
        [self.arryActivityTwitter removeAllObjects];
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

    [self.arryActivityTwitter removeAllObjects];

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

        [self.arryActivityTwitter addObject:userNotif];
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

    [self.arryActivityFB removeAllObjects];

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

#pragma mark - Short array of notification
/**************************************************************************************************
 Function to short array of notification
 **************************************************************************************************/

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
    if (self.arryActivity.count != 0){
        [self showAnimationOfActivity];
    } else {
            // self.tbleVwActivity.hidden = YES;
    }
}

- (void)showAnimationOfActivity {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.tbleVwActivity setHidden:NO];
    [UIView setAnimationDuration:3.0];
    [self.tbleVwActivity setAlpha:1];
    self.tbleVwActivity.hidden = NO;
    [UIView commitAnimations];

    self.loadingView.hidden = YES;
    [self.loadingView stopAnimation];
}

#pragma mark - UITable view Datasource

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

#pragma mark - UITable view Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {

    UserNotification *userNotify = [self.arryActivity objectAtIndex:indexPath.row];

    NSString *string = [NSString stringWithFormat:@"%@ on %@", userNotify.title, userNotify.notifType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake([Constant widthOfCommentLblOfTimelineAndProfile], 200)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];
    
    return (rect.size.height+45);
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

 */

@end

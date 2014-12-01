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
#import <Social/Social.h>

@interface UserNotificationViewController () {

    BOOL hasFacebook;
}

@property (nonatomic, strong) NSMutableArray *arryNotifi;
@property (nonatomic, strong) NSMutableArray *arryNotifiFB;
@property (nonatomic, strong) NSMutableArray *arryNotifiTwitter;

@end

@implementation UserNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Notification";
    self.title = @"Notification";
    self.navigationController.navigationBarHidden = NO;

    self.arryNotifi = [[NSMutableArray alloc]init];
    self.arryNotifiFB = [[NSMutableArray alloc]init];
    self.arryNotifiTwitter = [[NSMutableArray alloc]init];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];

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
        [sharedAppDelegate.spinner hide:YES];
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

                   [sharedAppDelegate.spinner hide:YES];
                   [Constant showAlert:@"Message" forMessage:@"No notification in Twitter account."];
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

        [self.arryNotifiTwitter addObject:userNotif];
    }

    [self shortArryOfAllFeeds];
}

#pragma mark - Convert date of twitter

- (NSString *)dateOfTwitter:(NSString *)createdDate {

    [sharedAppDelegate.spinner hide:YES];

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

           [self.arryNotifiFB addObject:userNotif];
       }
    }
    [self twitterNotification];
}

- (void)shortArryOfAllFeeds {

    [self.arryNotifi removeAllObjects]; //first remove all object

    [self.arryNotifi addObjectsFromArray:self.arryNotifiFB];
    [self.arryNotifi addObjectsFromArray:self.arryNotifiTwitter];

    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];//give key name
    NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];

    NSArray *sortedArray = [self.arryNotifi sortedArrayUsingDescriptors:sortDescriptors];
    [self.arryNotifi removeAllObjects];
    self.arryNotifi = [sortedArray mutableCopy];

    [tbleViewNotification reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryNotifi count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"UserNotification";
    UserNotificationCustomCell *cell;

    cell = (UserNotificationCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setNotificationIntableView:[self.arryNotifi objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {

    UserNotification *userNotify = [self.arryNotifi objectAtIndex:indexPath.row];

    NSString *string = [NSString stringWithFormat:@"%@ on %@", userNotify.title, userNotify.notifType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 200)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    return (rect.size.height+30);
}



@end

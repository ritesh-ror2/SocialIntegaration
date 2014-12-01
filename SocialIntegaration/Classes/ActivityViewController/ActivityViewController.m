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

@interface ActivityViewController ()

@property (nonatomic, strong) NSMutableArray *arryActivity;

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

- (void)viewDidLoad {

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

/*- (void)showActivityOfFbUser {

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

@end

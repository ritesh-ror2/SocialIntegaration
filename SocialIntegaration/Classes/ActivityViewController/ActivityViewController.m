//
//  ActivityViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 24/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ActivityViewController.h"
#import "UserInfo.h"

@interface ActivityViewController ()

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

        //[self fbUserAcitvity];
    [self showActivityOfFbUser];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) fbUserAcitvity {

    [FBSession openActiveSessionWithPublishPermissions:@[@"user_activities"]
                                       defaultAudience:FBSessionDefaultAudienceEveryone
                                          allowLoginUI:YES
                                     completionHandler:^(FBSession *session,
                                                         FBSessionState state,
                                                         NSError *error) {
                                         if (error) {

                                         } else {
                                             [self showActivityOfFbUser];
                                         }
                                     }];
}

- (void)showActivityOfFbUser {

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"user_activities"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {

    sharedAppDelegate.fbSession = session;

        //user_activities
    /* make the API call */
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
}

- (void)showActivityLog:(NSArray *)arryLogs {


    for (NSDictionary *dictActivity in arryLogs) {
        UserInfo *userInfo = [[UserInfo alloc]init];

        userInfo.fromId = [dictActivity valueForKey:@"id"];
        userInfo.strUserName = [dictActivity valueForKey:@"name"];
    }
}

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

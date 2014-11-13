//
//  ProfileViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ProfileViewController.h"
#import "Reachability.h"
#import "Constant.h"
#import "UserInfo.h"
#import "UserProfile.h"
#import "ProfileTableViewCustomCell.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ProfileViewController ()

@property (nonatomic, strong) NSMutableArray *arryOfFBUserFeed;
@property (nonatomic, strong) NSArray *arryOfViewController;

@end

@implementation ProfileViewController

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

    self.imgVwFBBackground.backgroundColor = [UIColor colorWithRed:70/256.0f green:106/256.0f blue:181/256.0f alpha:1.0];
    self.arryOfFBUserFeed = [[NSMutableArray alloc]init];

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];

    [self getFBUserInfo];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {

    [self.arryOfFBUserFeed removeAllObjects];
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

    if (![SLComposeViewController
          isAvailableForServiceType:SLServiceTypeFacebook]) {

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
		} else {

            NSDictionary *dictInfo = (NSDictionary *)result;
            [self getUserStatus];
            [self getFriendList];
            [self getProfileImg:dictInfo];
		}
	}];
}

#pragma mark - Get Profile image

- (void)getProfileImg:(NSDictionary *)userInfo {

    FBRequest *request = [FBRequest requestForGraphPath:@"me?fields=picture"];

	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (error) {
            [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
		} else {

            NSDictionary *dictInfo = (NSDictionary *)result;
            NSString *strProfileImg = [[[dictInfo objectForKey:@"picture"] objectForKey:@"data"]objectForKey:@"url"];
            [self convertFBUserInfoInModel:userInfo withProfileImg:strProfileImg];
		}
	}];
}

#pragma mark - Get friend list

- (void)getFriendList {

    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^( FBRequestConnection *connection, id result,  NSError *error) {
                              if (error) {
                                  [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
                              } else {
                                  NSDictionary *dictResult = (NSDictionary *)result;
                                  NSString *strFriendCount = [[dictResult valueForKey:@"summary"]valueForKey:@"total_count"];
                                  self.lblUserFrdList.text = [NSString stringWithFormat:@"%@ friends", strFriendCount];
                              }
                              
                          }];
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

    [self.arryOfFBUserFeed removeAllObjects];
    for (NSDictionary *dictData in arryPost) {

        NSDictionary *fromUser = [dictData objectForKey:@"from"];

        UserInfo *userInfo =[[UserInfo alloc]init];
        userInfo.strUserName = [fromUser valueForKey:@"name"];
        userInfo.fromId = [fromUser valueForKey:@"id"];
        userInfo.strUserPost = [dictData valueForKey:@"message"];
        userInfo.strUserSocialType = @"Facebook";
        userInfo.type = [dictData objectForKey:@"type"];
        userInfo.struserTime = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
        userInfo.strPostImg = [dictData valueForKey:@"picture"];
        [self.arryOfFBUserFeed addObject:userInfo];

        [self.tbleVwFeeds reloadData];
    }
}

#pragma mark - Convert profile into model class object

- (void)convertFBUserInfoInModel:(NSDictionary *)dictInfo withProfileImg:(NSString *)strProfileImg {

    UserProfile *userProfile = [[UserProfile alloc]init];
    userProfile.strUserName = [dictInfo objectForKey:@"name"];
    userProfile.urlUserImg = [NSURL URLWithString:strProfileImg];

    [self setFBUserInfo:userProfile];
}

#pragma mark - Show user profilr info

- (void)setFBUserInfo:(UserProfile*)userProfile {

    [sharedAppDelegate.spinner hide:YES];

    self.lblUserName.text = userProfile.strUserName;

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:userProfile.urlUserImg];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask.png"]];
            self.imgVwProfileImg.image = imgProfile;
        });
    });
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryOfFBUserFeed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tbleVwFeeds setHidden:NO];
    
    NSString *cellIdentifier = @"cellFeeds";
    ProfileTableViewCustomCell *cell;

    cell = (ProfileTableViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    [cell setValueInSocialTableViewCustomCell: [self.arryOfFBUserFeed objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryOfFBUserFeed objectAtIndex:indexPath.row];

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

//
//  InstagramProfileViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "InstagramProfileViewController.h"
#import "ProfileTableViewCustomCell.h"
#import "UserProfile.h"
#import "Reachability.h"
#import "Constant.h"

@interface InstagramProfileViewController ()

@property (nonatomic, strong) NSMutableArray *arryOfInstagrame;
@end

@implementation InstagramProfileViewController

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

    self.arryOfInstagrame = [[NSMutableArray alloc]init];
    self.imgVwFBBackground.backgroundColor = [UIColor colorWithRed:66/256.0f green:106/256.0f blue:151/256.0f alpha:1.0];
    [self getInstagrameIntegration];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {

    [self.arryOfInstagrame removeAllObjects];
}

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

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];

    // here i can set accessToken received on previous login
    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;

    if ([sharedAppDelegate.instagram isSessionValid]) {

        if (sharedAppDelegate.InstagramId.length != 0) {


            NSString *strInstagrameUserId = [NSString stringWithFormat:@"users/%@",sharedAppDelegate.InstagramId];
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strInstagrameUserId, @"method", nil]; //fetch feed
            [sharedAppDelegate.instagram requestWithParams:params
                                                  delegate:self];

            return;
        }
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"users/self/feed", @"method", nil]; //fetch feed
        [sharedAppDelegate.instagram requestWithParams:params
                                              delegate:self];
    } else {

        [sharedAppDelegate.spinner hide:YES];
        UIAlertView *alertVw = [[UIAlertView alloc]initWithTitle:@"Instagrame" message:@"Are You want to open Instagrame through safari." delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
        [alertVw show];
    }
}

#pragma mark - UIAlert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [sharedAppDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
}

#pragma mark - Login

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

    if (sharedAppDelegate.InstagramId.length == 0) {

        NSArray *arry = [result objectForKey:@"data"];

        NSString *strInstagrameId = [NSString stringWithFormat:@"%@", [[[[arry objectAtIndex:0] valueForKey:@"caption"]valueForKey:@"from"]valueForKey:@"id"]];
        sharedAppDelegate.InstagramId = strInstagrameId;
        NSString *strInstagrameUserId = [NSString stringWithFormat:@"users/%@",sharedAppDelegate.InstagramId];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strInstagrameUserId, @"method", nil]; //fetch feed
        [sharedAppDelegate.instagram requestWithParams:params
                                              delegate:self];
    } else {

        if ([[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {

            [self convertUserPostIntoModel:[result objectForKey:@"data"]];
            return;
        }
        [self convertProfileData:[result objectForKey:@"data"]];
    }
}

#pragma mark - Convert user post in to model class

- (void)convertUserPostIntoModel:(NSArray *)arryOfInstagrame {

    [self.arryOfInstagrame removeAllObjects];
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
        [self.arryOfInstagrame addObject:userInfo];

        NSLog(@"%@", self.arryOfInstagrame);
    }
    [self.tbleVwInstagramPost reloadData];
}

#pragma mark - Convert profile Info

- (void)convertProfileData:(NSDictionary *)dictInfo {

    UserProfile *userProfile = [[UserProfile alloc]init];
    if ([dictInfo isKindOfClass: [NSDictionary class]]) {

        NSDictionary *dictCounts = [dictInfo objectForKey:@"counts"];
        userProfile.followers = [dictCounts valueForKey:@"followed_by"];
        userProfile.following = [dictCounts valueForKey:@"follows"];
        userProfile.post = [dictCounts valueForKey:@"media"];
        userProfile.userId = [dictInfo valueForKey:@"id"];
        userProfile.urlUserImg = [NSURL URLWithString:[dictInfo valueForKey:@"profile_picture"]];
        userProfile.strUserName = [dictInfo valueForKey:@"full_name"];
        [self getPostOfUser:userProfile.userId];
        [self showProfileData:userProfile];
    }
}

#pragma mark - Request to get user own post

- (void)getPostOfUser:(NSString *)strUerId {

    NSString *strMethod = [NSString stringWithFormat:@"users/%@/media/recent/",strUerId];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strMethod, @"method", nil]; //fetch feed
    [sharedAppDelegate.instagram requestWithParams:params
                                          delegate:self];
}

#pragma mark - Show Profile data

- (void)showProfileData:(UserProfile *)userProfile {

    [sharedAppDelegate.spinner hide:YES];
    self.lblUserName.text = userProfile.strUserName;
    self.lblUserPost.text = [NSString stringWithFormat:@"%i", userProfile.post.intValue];
    self.lblUserFollowes.text = [NSString stringWithFormat:@"%i", userProfile.followers.intValue];
    self.lblUserFollowing.text = [NSString stringWithFormat:@"%i", userProfile.following.intValue];
    self.lblStatus.text = userProfile.status;

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

#pragma mark - UITable View Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryOfInstagrame count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tbleVwInstagramPost setHidden:NO];
    NSString *cellIdentifier = @"cellFeeds";
    ProfileTableViewCustomCell *cell;

    cell = (ProfileTableViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    [cell setValueInSocialTableViewCustomCell: [self.arryOfInstagrame objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryOfInstagrame objectAtIndex:indexPath.row];

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

@end

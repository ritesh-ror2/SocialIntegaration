//
//  ShowOtherUserProfileViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 20/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShowOtherUserProfileViewController.h"
#import "Constant.h"
#import <Social/Social.h>

@interface ShowOtherUserProfileViewController () {

    NSString *strProfileImg;
}

@end

@implementation ShowOtherUserProfileViewController

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

    NSString *name;
    NSString *notificationType;

    if (self.userInfo != nil) {
        name = self.userInfo.userName;
        notificationType = self.userInfo.userSocialType;
    } else {
        name = self.userNotification.name;
        notificationType = self.userNotification.notifType;
    }

    if ([notificationType isEqualToString:@"Facebook"]) {

        lblName.text = name;
        [self showProfileImageOfFb];
        imgVwBgImg.image = [UIImage imageNamed:@"facebook-bg.png"];
    } else  if ([notificationType isEqualToString:@"Twitter"]) {

        [self setTwitterUserInformation];
        imgVwBgImg.image = [UIImage imageNamed:@"twitter-bg.png"];
    } else {
            // [self setProfileImageOfTwitterAndInstagram:self.userInfo];
        imgVwBgImg.image = [UIImage imageNamed:@"instagram-bg.png"];
    }
    [self.view bringSubviewToFront:ImgVwCircle];
    sharedAppDelegate.isFirstTimeLaunch = NO;

    if(IS_IPHONE_6_IOS8 || IS_IPHONE_6P_IOS8) {

        [self setFrameForIPhone6and6Plus];
    }

    NSArray *arry = self.navController.navigationBar.subviews;
    for (UIView *vw in arry){

        if ([vw isKindOfClass:[UIPageControl class]]) {
            vw.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


#pragma mark - Set frame for iphone6 and 6+

- (void)setFrameForIPhone6and6Plus {

    ImgVwProfile.frame = CGRectMake((self.view.frame.size.width - 96)/2, ImgVwProfile.frame.origin.y, 96, 96);
    self.imgVwBorderMask.frame = CGRectMake((self.view.frame.size.width - 100)/2, self.imgVwBorderMask.frame.origin.y, 100, 100);

    int xAxis;
    if (IS_IPHONE_6P_IOS8) {
        xAxis = 148;
    } else {
        xAxis = 136;
    }
    lblFolloweCount.frame = CGRectMake(xAxis, lblFolloweCount.frame.origin.y, lblFolloweCount.frame.size.width, lblFolloweCount.frame.size.height);
    lblFollower.frame = CGRectMake(xAxis, lblFollower.frame.origin.y, lblFollower.frame.size.width, lblFollower.frame.size.height);

        // imgVwLine1.frame = CGRectMake(xAxis - 15 , 227, 1, 30);
        // imgVwLine2.frame = CGRectMake(xAxis + lblFollower.frame.size.width + 15 , 227, 1, 30);
    imgVwLine1.frame = CGRectMake(xAxis - 15 , imgVwLine1.frame.origin.y, 1, 30);
    imgVwLine2.frame = CGRectMake(xAxis + lblFollower.frame.size.width + 15 , imgVwLine2.frame.origin.y, 1, 30);
}

#pragma mark - Show Twitter user information
/**************************************************************************************************
 Function to show twitter user information
 **************************************************************************************************/

- (void)setTwitterUserInformation {

    lblTweetCount.hidden = NO;
    lblFollower.hidden = NO;
    lblFolloweCount.hidden = NO;
    lblFolloeingCount.hidden = NO;
    lblFollowing.hidden = NO;
    lblTweet.hidden = NO;
    imgVwLine1.hidden = NO;
    imgVwLine2.hidden = NO;

    NSDictionary *dictOtherUser;
    if (self.userInfo != nil) {
        dictOtherUser = self.userInfo.dicOthertUser;
    } else {
        dictOtherUser = self.userNotification.dicOthertUser;
    }
    [self setProfileImageOfTwitterAndInstagram:[dictOtherUser objectForKey:@"profile_image_url"]];
    lblFolloeingCount.text = [NSString stringWithFormat:@"%li",(long)[[dictOtherUser objectForKey:@"friends_count"] integerValue]];
    lblFolloweCount.text = [NSString stringWithFormat:@"%li",(long)[[dictOtherUser objectForKey:@"followers_count"]integerValue]];
    lblTweetCount.text = [NSString stringWithFormat:@"%li",(long)[[dictOtherUser objectForKey:@"listed_count"]integerValue]] ;
    lblName.text = [dictOtherUser objectForKey:@"name"];

    if (self.userInfo.isFollowing == 1){
        [btnRequestOrFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
        [btnRequestOrFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

#pragma mark - Follow/Unfollow to twitter user
/**************************************************************************************************
 Function to follow and unfollow in twitter
 **************************************************************************************************/

- (IBAction)sendFrienRequest:(id)sender {

    if ([btnRequestOrFollow.titleLabel.text isEqualToString:@"Unfollow"]) {

        NSDictionary *dictOtherUser;
        if (self.userInfo != nil) {
            dictOtherUser = self.userInfo.dicOthertUser;
        } else {
            dictOtherUser = self.userNotification.dicOthertUser;
        }

        NSString *strUserId = [NSString stringWithFormat:@"%li",(long)[[dictOtherUser valueForKey:@"id"]integerValue]];
        NSDictionary *param = @{@"user_id": strUserId};
        NSURL *requestURL = [NSURL URLWithString:TWITTER_FRIEND_DESTROY];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                      URL:requestURL parameters:param];

        timelineRequest.account = sharedAppDelegate.twitterAccount;

        [timelineRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

           NSLog(@"%@ !#" , [error description]);
           NSArray *arryTwitte = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];

           if (arryTwitte.count != 0) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [btnRequestOrFollow setTitle:@"Follow" forState:UIControlStateNormal];
               });
           }
         }];
        return;
    } else if ([btnRequestOrFollow.titleLabel.text isEqualToString:@"Follow"]) {

        NSDictionary *dictOtherUser;
        if (self.userInfo != nil) {
            dictOtherUser = self.userInfo.dicOthertUser;
        } else {
            dictOtherUser = self.userNotification.dicOthertUser;
        }

        NSString *strUserId = [NSString stringWithFormat:@"%li",(long)[[dictOtherUser valueForKey:@"id"]integerValue]];
        NSDictionary *param = @{@"user_id": strUserId, @"follow":@"true"};
        NSURL *requestURL = [NSURL URLWithString:TWITTER_FRIEND_CREATE];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                      URL:requestURL parameters:param];

        timelineRequest.account = sharedAppDelegate.twitterAccount;

        [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
           NSLog(@"%@ !#" , [error description]);
           NSArray *arryTwitte = [NSJSONSerialization
                                  JSONObjectWithData:responseData
                                  options:NSJSONReadingMutableLeaves
                                  error:&error];

           if (arryTwitte.count != 0) {
               NSLog(@"%@", arryTwitte);
               dispatch_async(dispatch_get_main_queue(), ^{
                   [btnRequestOrFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
               });
           }
         }];
        return;
    }

  /*  NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObject:self.userInfo.fromId forKey:@"to"];
    NSString *message = @"Send Request";
    NSString *title = @"TITLE";

    FBSession *facebookSession = sharedAppDelegate.fbSession; //You may changed this if you are not using parse.com

    [FBWebDialogs presentRequestsDialogModallyWithSession:facebookSession
                                                  message:message
                                                    title:title
                                               parameters:params handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
       NSLog(@"%@", [error localizedDescription]);
       if (error)
         {
               // Case A: Error launching the dialog or sending request.
           NSLog(@"Error sending request.");
         }
       else
         {
           if (result == FBWebDialogResultDialogNotCompleted)
             {
                   // Case B: User clicked the "x" icon
               NSLog(@"User canceled request.");
             }
           else
             {
               NSLog(@"Request Sent. %@", params);
             }
         }

     }];*/

 /*   NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"friend_request"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;


    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys: @"Please accept my request", @"message", nil];//@"[FRIEND ID]/apprequests"

     NSString *strUserId = [NSString stringWithFormat:@"/%@/apprequests", self.userInfo.fromId];

    [FBRequestConnection startWithGraphPath:strUserId
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {
                                  NSLog(@"%@", [error localizedDescription]);
                              } else {
                                  NSLog(@"success");
                              }
    }];
    }];*/
}

#pragma mark - Set profile image of twitter and Instagram
/**************************************************************************************************
 Function to set profile image of twitter and instagram
 **************************************************************************************************/

- (void)setProfileImageOfTwitterAndInstagram:(NSString *)profileImg {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            ImgVwProfile.image = imgProfile;
        });
    });
}

#pragma mark - Set User profile images
/**************************************************************************************************
 Function to show Fb user profile image
 **************************************************************************************************/

- (void)showProfileImageOfFb {

    NSString *strId;
    if (self.userInfo != nil) {
        strId = self.userInfo.fromId;
    } else {
        strId = self.userNotification.fromId;
    }
        // load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", strId]];
	dispatch_queue_t profileURLQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(profileURLQueue, ^{

        NSData *result = [NSData dataWithContentsOfURL:jsonURL];

        if (result) {

			NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:result
																	   options:NSJSONReadingMutableContainers
																		 error:NULL];
            NSLog(@"** %@", resultDict);

            NSString *strProfileImg1 = [[resultDict valueForKey:@"data"] valueForKey:@"url"];
            strProfileImg = strProfileImg1;
            if (strProfileImg.length == 0) {
                strProfileImg = @"user-selected.png";
                UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed:strProfileImg] withMask:[UIImage imageNamed:@"list-mask.png"]];
                ImgVwProfile.image = imgProfile;
                return ;
            }

            dispatch_queue_t userImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(userImageQueue, ^{

                NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strProfileImg]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    UIImage *img = [UIImage imageWithData:image];
                    UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
                    
                    ImgVwProfile.image = imgProfile;
                });
            });
		}
	});
}

#pragma mark - Cancel btn tapped
/**************************************************************************************************
 Function to cancel btn
 **************************************************************************************************/

- (IBAction)cancelBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

@end

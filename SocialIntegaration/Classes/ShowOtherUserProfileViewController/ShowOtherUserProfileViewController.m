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

    if ([self.userInfo.strUserSocialType isEqualToString:@"Facebook"]) {
        lblName.text = self.userInfo.strUserName;
        [self showProfileImage:self.userInfo];
        imgVwBgImg.image = [UIImage imageNamed:@"facebook-bg.png"];
    } else  if ([self.userInfo.strUserSocialType isEqualToString:@"Twitter"]) {

        [self setTwitterUserInformation];
        imgVwBgImg.image = [UIImage imageNamed:@"twitter-bg.png"];
    } else {
            // [self setProfileImageOfTwitterAndInstagram:self.userInfo];
        imgVwBgImg.image = [UIImage imageNamed:@"instagram-bg.png"];
    }
    [self.view bringSubviewToFront:ImgVwCircle];
}

- (void)setTwitterUserInformation {

    lblTweetCount.hidden = NO;
    lblFollower.hidden = NO;
    lblFolloweCount.hidden = NO;
    lblFolloeingCount.hidden = NO;
    lblFollowing.hidden = NO;
    lblTweet.hidden = NO;
    imgVwLine1.hidden = NO;
    imgVwLine2.hidden = NO;

    NSDictionary *dictOtherUser = self.userInfo.dicOthertUser;

    [self setProfileImageOfTwitterAndInstagram:[dictOtherUser objectForKey:@"profile_image_url"]];
    lblFolloeingCount.text = [NSString stringWithFormat:@"%i",[[dictOtherUser objectForKey:@"friends_count"] integerValue] ];
    lblFolloweCount.text = [NSString stringWithFormat:@"%i",[[dictOtherUser objectForKey:@"followers_count"]integerValue] ];
    lblTweetCount.text = [NSString stringWithFormat:@"%i",[[dictOtherUser objectForKey:@"listed_count"]integerValue] ] ;
    lblName.text = [dictOtherUser objectForKey:@"name"];

    if (self.userInfo.isFollowing == 1){
        [btnRequestOrFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
        [btnRequestOrFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }
}


- (IBAction)sendFrienRequest:(id)sender {

    if ([btnRequestOrFollow.titleLabel.text isEqualToString:@"Unfollow"]) {

        NSDictionary *dictOtherUser = self.userInfo.dicOthertUser;

        NSString *strUserId = [NSString stringWithFormat:@"%i",[[dictOtherUser valueForKey:@"id"]integerValue]];
        NSDictionary *param = @{@"user_id": strUserId};
        NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/destroy.json"];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                      URL:requestURL parameters:param];

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
                   [btnRequestOrFollow setTitle:@"Follow" forState:UIControlStateNormal];
               });
           }
         }];
        return;
    } else if ([btnRequestOrFollow.titleLabel.text isEqualToString:@"Follow"]) {

        NSDictionary *dictOtherUser = self.userInfo.dicOthertUser;

        NSString *strUserId = [NSString stringWithFormat:@"%i",[[dictOtherUser valueForKey:@"id"]integerValue]];
        NSDictionary *param = @{@"user_id": strUserId};
        NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/update.json"];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                      URL:requestURL parameters:param];

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
                   [btnRequestOrFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
               });
           }
         }];
        return;
    }
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

                              } else {
                                  NSLog(@"success");
                              }
                          }];
}

#pragma mark - Set profile image of twitter and Instagram

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

- (void)showProfileImage:(UserInfo *)objUserInfo {

        // load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", objUserInfo.fromId]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  TwitterProfileViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "TwitterProfileViewController.h"
#import <Accounts/Accounts.h>
#import "UserInfo.h"
#import "Reachability.h"
#import "UserProfile.h"
#import <Social/Social.h>
#import "Constant.h"
#import "UserProfile+DatabaseHelper.h"
#import "ProfileTableViewCustomCell.h"

@interface TwitterProfileViewController ()

@property (nonatomic, strong) NSMutableArray *arryTweeterProfileInfo;
@property (nonatomic, strong) ACAccount *twitterAccount;
@end

@implementation TwitterProfileViewController

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

    self.imgVwFBBackground.backgroundColor = [UIColor colorWithRed:89/256.0f green:157/256.0f blue:247/256.0f alpha:1.0];
    self.arryTweeterProfileInfo = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {

    [self.arryTweeterProfileInfo removeAllObjects];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];

    [self getUserInfoFromTwitter];
}

#pragma mark - Request to get user info

- (void)getUserInfoFromTwitter {

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

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        [sharedAppDelegate.spinner hide:YES];
        return;
    } else {

        UserProfile *userProfile = [UserProfile getProfile:@"Twitter"];
        [self showProfile:userProfile];
        [self getUserTweets:userProfile.userId];

    }
}

#pragma mark - Convert profile info into user profile
//
//- (void)convertProfileInfo:(NSDictionary *)dictData {
//
//    UserProfile *userProfile = [[UserProfile alloc]init];
//
//    userProfile.userName = [dictData valueForKey:@"screen_name"];
//    userProfile.userImg = [dictData valueForKey:@"profile_image_url"];
//    userProfile.following = [dictData valueForKey:@"friends_count"];
//    userProfile.tweet = [dictData valueForKey:@"statuses_count"];
//    userProfile.followers = [dictData valueForKey:@"followers_count"];
//    userProfile.type = [[dictData valueForKey:@"status"]valueForKey:@"text"];
//    userProfile.userId  =  [NSString stringWithFormat:@"%lf",[[[dictData valueForKey:@"status"]valueForKey:@"id"] doubleValue]];
//
//    [self getUserTweets:userProfile.userId];
//    [self showProfile:userProfile];
//}

#pragma mark - Request to get user own tweet

- (void)getUserTweets:(NSString*) userId{

    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error) {

    if (granted == YES) {
        NSArray *arrayOfAccounts = [account
                                       accountsWithAccountType:accountType];

    if ([arrayOfAccounts count] > 0) {

        self.twitterAccount = [arrayOfAccounts lastObject];
        NSString *strRequest = [NSString stringWithFormat:TWITTER_USER_OWN_STATUS];

        NSURL *requestURL = [NSURL URLWithString:strRequest];
        SLRequest *timelineRequest1 = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodGET
                                      URL:requestURL parameters:nil];

        timelineRequest1.account = self.twitterAccount;

        [timelineRequest1 performRequestWithHandler:
         ^(NSData *responseData, NSHTTPURLResponse
           *urlResponse, NSError *error) {

             if (error) {

                 [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_AUTHEN];
                 return ;
             } else {

                 NSLog(@"%@ !#" , [error description]);
                 NSArray *arryTwitte = [NSJSONSerialization
                                        JSONObjectWithData:responseData
                                        options:NSJSONReadingMutableLeaves
                                        error:&error];

                 if (arryTwitte.count != 0) {

                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self convertDataOfTwitterIntoModel:arryTwitte];
                     });
                }
                }
                }];
            }
        }
     }];
}

#pragma mark - Show profile information

- (void)showProfile:(UserProfile *)userProfile {

    self.lblUserName.text = userProfile.userName;
    self.lblUserTweet.text = userProfile.tweet;
    self.lblUserFollowes.text =  userProfile.followers;
    self.lblUserFollowing.text = userProfile.following;
    self.lblStatus.text = userProfile.status;

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(postImageQueue, ^{

        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask.png"]];
            self.imgVwProfileImg.image = imgProfile;
        });
    });
}

#pragma mark - Convert date into "YYYY-dd-mm" formate

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

#pragma mark - Convert data of twitter in to model class

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    [self.arryTweeterProfileInfo removeAllObjects];

    @autoreleasepool  {

        for (NSDictionary *dictData in arryPost) {

            NSLog(@"**%@", dictData);

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];

            UserInfo *userInfo =[[UserInfo alloc]init];
            userInfo.strUserName = [postUserDetailDict valueForKey:@"name"];
            userInfo.fromId = [postUserDetailDict valueForKey:@"id"];
            userInfo.strUserImg = [postUserDetailDict valueForKey:@"profile_image_url"];

            NSArray *arryMedia = [[dictData objectForKey:@"extended_entities"] objectForKey:@"media"];

            if (arryMedia.count>0) {
                userInfo.strPostImg = [[arryMedia objectAtIndex:0] valueForKey:@"media_url"];
            }
            userInfo.strUserPost = [dictData valueForKey:@"text"];
            userInfo.strUserSocialType = @"Twitter";
            userInfo.type = [dictData objectForKey:@"type"];
            NSString *strDate = [self dateOfTwitter:[dictData objectForKey:@"created_at"]];
            userInfo.struserTime = [Constant convertDateOFTweeter:strDate];
            [self.arryTweeterProfileInfo addObject:userInfo];
        }
    }
    [sharedAppDelegate.spinner hide:YES];
    [self.tbleVwTweeterFeeds reloadData];
}

#pragma mark - UITable view Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryTweeterProfileInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tbleVwTweeterFeeds setHidden:NO];
    
    NSString *cellIdentifier = @"cellFeeds";
    ProfileTableViewCustomCell *cell;

    cell = (ProfileTableViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValueInSocialTableViewCustomCell: [self.arryTweeterProfileInfo objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryTweeterProfileInfo objectAtIndex:indexPath.row];

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

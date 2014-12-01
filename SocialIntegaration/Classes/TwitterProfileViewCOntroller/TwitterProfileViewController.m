//
//  TwitterProfileViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "TwitterProfileViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "CustomTableCell.h"
#import "UserInfo.h"
#import "Reachability.h"
#import "UserProfile.h"
#import "CommentViewController.h"
#import "Constant.h"
#import "UserProfile+DatabaseHelper.h"
#import "ProfileTableViewCustomCell.h"

@interface TwitterProfileViewController () <CustomTableCellDelegate>

@property (nonatomic, strong) NSMutableArray *arrySelfTweets;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex; 
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

    self.arrySelfTweets = [[NSMutableArray alloc]init];
    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];

    if (IS_IOS7) {
        [self.tbleVwTweeterFeeds setSeparatorInset:UIEdgeInsetsZero];
    }
    self.tbleVwTweeterFeeds.hidden = NO;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {

    [self.arryTappedCell removeAllObjects];
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

    [self.arrySelfTweets removeAllObjects];
    [self.arrySelectedIndex removeAllObjects];

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
            userInfo.statusId =[dictData valueForKey:@"id"];
            userInfo.favourated = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"favorited"] integerValue]];

            userInfo.screenName = [postUserDetailDict valueForKey:@"screen_name"];
            userInfo.retweeted = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"retweeted"] integerValue]];
            userInfo.retweetCount = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"retweet_count"] integerValue]];
            userInfo.favourateCount = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"favorite_count"] integerValue]];

            NSString *strDate = [self dateOfTwitter:[dictData objectForKey:@"created_at"]];
            userInfo.struserTime = [Constant convertDateOFTweeter:strDate];
            [self.arrySelfTweets addObject:userInfo];
            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [sharedAppDelegate.spinner hide:YES];
    [self.tbleVwTweeterFeeds reloadData];
}

#pragma mark - UITable view Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"** %i",self.arrySelfTweets.count);
    return [self.arrySelfTweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  /*  [self.tbleVwTweeterFeeds setHidden:NO];
    
    NSString *cellIdentifier = @"cellFeeds";
    ProfileTableViewCustomCell *cell;

    cell = (ProfileTableViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValueInSocialTableViewCustomCell: [self.arryTweeterProfileInfo objectAtIndex:indexPath.row]];

    return cell;*/
    [self.tbleVwTweeterFeeds setHidden:NO];
    NSString *cellIdentifier = @"cellIdentifier";
    CustomTableCell *cell;

    cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSArray *arryObjects;
    if (cell == nil) {

        arryObjects = [[NSBundle mainBundle]loadNibNamed:@"CustomTableCell" owner:nil options:nil];
        cell = [arryObjects objectAtIndex:0];
        cell.customCellDelegate = self;

    }

    if(indexPath.row < [self.arrySelfTweets count]){

            //  self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell:[self.arrySelfTweets objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:NO];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arrySelfTweets objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    if (objUserInfo.strPostImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + 197);
            }
        }
        return(rect.size.height + 165);
    }

    for (NSString *index in self.arrySelectedIndex) {

        if (index.integerValue == indexPath.row) {
            return(rect.size.height + 90);
        }
    }
    return (rect.size.height + 58);//183 is height of other fixed content
}

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    NSLog(@"****%@***", self.arrySelectedIndex);
        //your code here

    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwTweeterFeeds beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwTweeterFeeds reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwTweeterFeeds endUpdates];
}


/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryTweeterProfileInfo objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    if (objUserInfo.strPostImg.length != 0) {
        return(rect.size.height + 160);
    }
    return (rect.size.height + 60);//183 is height of other fixed content
}*/

@end

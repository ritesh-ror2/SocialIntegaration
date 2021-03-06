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
#import "ShowOtherUserProfileViewController.h"
#import "ProfileTableViewCustomCell.h"
#import "UIFont+Helper.h"

@interface TwitterProfileViewController () <CustomTableCellDelegate> {

    int heightOfRowImg;
    int widthOfCommentLbl;
    UserProfile *userProfile;

    NSInteger indexPost;
}

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

    if (!IS_IPHONE5) {

        self.btnFollowing.hidden = YES;
        self.btnEdit.frame = self.btnFollowing.frame;
    }

    self.tbleVwTweeterFeeds.hidden = NO;

    if(IS_IPHONE_6_IOS8 || IS_IPHONE_6P_IOS8) {

        [self setFrameForIPhone6and6Plus];

        /*[self.lblUserName  setFont:[UIFont fontWithMediumWithSize:15]];
        [self.lblStatus setFont:[UIFont fontWithMediumWithSize:15]];

        [self.lblUserFollowes setFont:[UIFont fontWithRegularWithSize:14]];
        [self.lblUserFollowing setFont:[UIFont fontWithRegularWithSize:14]];
        [self.lblUserTweet setFont:[UIFont fontWithRegularWithSize:14]];
        */
    }
    self.tbleVwTweeterFeeds.separatorColor = [UIColor clearColor];
    heightOfRowImg = [Constant heightOfCellInTableVw];
    widthOfCommentLbl = [Constant widthOfCommentLblOfTimelineAndProfile];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {

        //=======
        //>>>>>>> 8bb65de51a914a175ec2eb603298f2f67e902f45
    [super viewWillDisappear:animated];
    [self.arryTappedCell removeAllObjects];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [[NSUserDefaults standardUserDefaults]setInteger:1 forKey:@"ProfilePage"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [Constant showNetworkIndicator];
    [self getUserInfoFromTwitter];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Set frame for iphone6 and 6+

- (void)setFrameForIPhone6and6Plus {

    self.imgVwProfileImg.frame = CGRectMake((self.view.frame.size.width - 82)/2, self.imgVwProfileImg.frame.origin.y+35, 82, 82);
    self.imgVwBorderMask.frame = CGRectMake((self.view.frame.size.width - 84)/2, self.imgVwBorderMask.frame.origin.y+35, 84, 84);
    self.lblUserName.frame = CGRectMake((self.view.frame.size.width - self.lblUserName.frame.size.width)/2, self.imgVwBorderMask.frame.origin.y+self.imgVwBorderMask.frame.size.height+10, self.lblUserName.frame.size.width, 21);
    self.lblStatus.frame = CGRectMake((self.view.frame.size.width - self.lblStatus.frame.size.width)/2, self.lblUserName.frame.origin.y+self.lblUserName.frame.size.height+10, self.lblStatus.frame.size.width, self.lblStatus.frame.size.height);


    int xAxis;
    if (IS_IPHONE_6P_IOS8) {
        xAxis = 148;
    } else {
        xAxis = 136;
    }
    self.lblUserFollowes.frame = CGRectMake(xAxis, self.lblUserFollowes.frame.origin.y, self.lblUserFollowes.frame.size.width, self.lblUserFollowes.frame.size.height);
    self.lblUserFollowersTitle.frame = CGRectMake(xAxis, self.lblUserFollowersTitle.frame.origin.y, self.lblUserFollowersTitle.frame.size.width, self.lblUserFollowersTitle.frame.size.height);

    self.imgVwLine1.frame = CGRectMake(xAxis - 15 , self.imgVwLine1.frame.origin.y, 1, 30);
    self.imgVwLine2.frame = CGRectMake(xAxis + self.lblUserFollowersTitle.frame.size.width + 15 , self.imgVwLine2.frame.origin.y, 1, 30);
}

#pragma mark - Request to get user info
/**************************************************************************************************
 Function to request twitter user info
 **************************************************************************************************/

- (void)getUserInfoFromTwitter {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        self.tbleVwTweeterFeeds.hidden = YES;
        [Constant hideNetworkIndicator];

        return;
    }

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == NO) {

            // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        self.lblUserName.text = @"User is not login by settings.";
        self.tbleVwTweeterFeeds.hidden = YES;
        dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(postImageQueue, ^{
            UIImage *image = [UIImage imageNamed:@"user-selected.png"];
            NSData *dataImg = UIImagePNGRepresentation(image);

            dispatch_async(dispatch_get_main_queue(), ^{

                UIImage *img = [UIImage imageWithData:dataImg];
                UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask.png"]];
                self.imgVwProfileImg.image = imgProfile;
            });
        });

        [Constant hideNetworkIndicator];
        return;
    } else {

        self.tbleVwTweeterFeeds.hidden = NO;
        userProfile = [UserProfile getProfile:@"Twitter"];
        [self showProfile:userProfile];
        [self getUserTweets:userProfile.userId];
    }
}

#pragma mark - Request to get user own tweet
/**************************************************************************************************
 Function to request to get user own tweet
 **************************************************************************************************/

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

                     // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_AUTHEN];
                 self.lblUserName.text = @"User is not login by settings of app.";
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

#pragma mark - Show user profile information
/**************************************************************************************************
 Function to show user profile information
 **************************************************************************************************/

- (void)showProfile:(UserProfile *)userProfile1 {

    self.lblUserName.text = userProfile1.userName;
    self.lblStatus.text = userProfile1.description;
    self.lblUserTweet.text = userProfile1.tweet;
    self.lblUserFollowes.text =  userProfile1.followers;
    self.lblUserFollowing.text = userProfile1.following;
    self.lblStatus.text = userProfile1.description;

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(postImageQueue, ^{

        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile1.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask.png"]];
            self.imgVwProfileImg.image = imgProfile;
        });
    });
}

#pragma mark - Convert data of twitter in to model class
/**************************************************************************************************
 Function to convert data of twitter in to model class
 **************************************************************************************************/

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    [self.arrySelfTweets removeAllObjects];
    [self.arrySelectedIndex removeAllObjects];

    @autoreleasepool  {

        for (NSDictionary *dictData in arryPost) {

            NSLog(@"**%@", dictData);

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];

            UserInfo *userInfo =[[UserInfo alloc]init];
            userInfo.userName = [postUserDetailDict valueForKey:@"name"];
            userInfo.fromId = [postUserDetailDict valueForKey:@"id"];
            userInfo.userProfileImg = [postUserDetailDict valueForKey:@"profile_image_url"];

            NSArray *arryMedia = [[dictData objectForKey:@"extended_entities"] objectForKey:@"media"];

            if (arryMedia.count>0) {
                userInfo.postImg = [[arryMedia objectAtIndex:0] valueForKey:@"media_url"];
            }
            userInfo.strUserPost = [dictData valueForKey:@"text"];
            userInfo.userSocialType = @"Twitter";
            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.statusId =[dictData valueForKey:@"id"];
            userInfo.favourated = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"favorited"] integerValue]];

            userInfo.screenName = [postUserDetailDict valueForKey:@"screen_name"];
            userInfo.retweeted = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"retweeted"] integerValue]];
            userInfo.retweetCount = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"retweet_count"] integerValue]];
            userInfo.favourateCount = [NSString stringWithFormat:@"%li", (long)[[dictData objectForKey:@"favorite_count"] integerValue]];

            NSString *strDate = [Constant convertDateOfTwitterInDatabaseFormate:[dictData objectForKey:@"created_at"]];
            userInfo.time = [Constant convertDateOFTwitter:strDate];

            [self.arrySelfTweets addObject:userInfo];
            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [Constant hideNetworkIndicator];
    [self.tbleVwTweeterFeeds reloadData];
}

#pragma mark - UITable view Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        // NSLog(@"** %i",self.arrySelfTweets.count);
    return [self.arrySelfTweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

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

    BOOL isSelected = NO;
    if (self.arryTappedCell.count > indexPath.row) {
     isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];
    }

    if(indexPath.row < [self.arrySelfTweets count]){

    [cell setValueInSocialTableViewCustomCell:[self.arrySelfTweets objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:NO withOtherTimeline:YES withProfile:YES];
    }
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arrySelfTweets objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(widthOfCommentLbl, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:17.0]}
                                       context:nil];

    if (objUserInfo.postImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + heightOfRowImg + 35);
            }
        }
        return(rect.size.height + heightOfRowImg + 13);
    }

    for (NSString *index in self.arrySelectedIndex) {

        if (index.integerValue == indexPath.row) {
            return(rect.size.height + 90);
        }
    }
    return (rect.size.height + 65);//183 is height of other fixed content
}

#pragma mark - Custom cell Delegates
/**************************************************************************************************
 Function to custom cell Delegates to show user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
    vwController.userInfo = userInfo;
    [self.navigationController pushViewController:vwController animated:YES];
}

/**************************************************************************************************
 Function to go to detail view
 **************************************************************************************************/

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

/**************************************************************************************************
 Function when first time cell will be tapped
 **************************************************************************************************/

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    [self.arrySelectedIndex removeAllObjects];

    [self.tbleVwTweeterFeeds beginUpdates];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPost inSection:0];
    [self.tbleVwTweeterFeeds reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwTweeterFeeds endUpdates];

    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    [self.arryTappedCell replaceObjectAtIndex:indexPost withObject:[NSNumber numberWithBool:NO]];
    indexPost = cellIndex;

    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwTweeterFeeds beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwTweeterFeeds reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

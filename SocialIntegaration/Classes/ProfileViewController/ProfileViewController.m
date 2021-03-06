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
#import "CustomTableCell.h"
#import "UserProfile+DatabaseHelper.h"
#import "ProfileTableViewCustomCell.h"
#import "CommentViewController.h"
#import "ShowOtherUserProfileViewController.h"
#import "UIFont+Helper.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface ProfileViewController () <CustomTableCellDelegate> {

    int heightOfRowImg;
    NSInteger indexPost;
    int widthOfCommentLbl;
}

@property (nonatomic, strong) NSMutableArray *arryOfFBUserFeed;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;
@property (nonatomic, strong) NSArray *arryOfViewController;

@end

@implementation ProfileViewController

@synthesize btnEdit, btnRequest;

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
        //
    [self setNeedsStatusBarAppearanceUpdate];
    self.imgVwBorderStatus.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    // self.imgVwFBBackground.backgroundColor = [UIColor colorWithRed:70/256.0f green:106/256.0f blue:181/256.0f alpha:1.0];
    [self.view sendSubviewToBack:self.imgVwFBBackground];
    self.arryOfFBUserFeed = [[NSMutableArray alloc]init];
    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];

    self.lblUserName.hidden = NO;
    self.lblUserFrdList.hidden = NO;
    self.imgVwProfileImg.hidden = NO;

    if (!IS_IPHONE5) {

        self.btnRequest.hidden = YES;
        self.btnEdit.frame = self.btnRequest.frame;
    }
    
    if(IS_IPHONE_6_IOS8 || IS_IPHONE_6P_IOS8) {

            // [self.lblUserName setFont:[UIFont fontWithMediumWithSize:15]];
            // [self.lblUserFrdList setFont:[UIFont fontWithMediumWithSize:15]];
        [self setFrameForIPhone6and6Plus];
     }

    self.tbleVwFeeds.separatorColor = [UIColor clearColor];

    heightOfRowImg = [Constant heightOfCellInTableVw];
    widthOfCommentLbl = [Constant widthOfCommentLblOfTimelineAndProfile];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self setNeedsStatusBarAppearanceUpdate];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [Constant showNetworkIndicator];

    [[NSUserDefaults standardUserDefaults]setInteger:0 forKey:@"ProfilePage"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [self.arrySelectedIndex removeAllObjects];
    //[self.tbleVwFeeds reloadData];

    [self getFBUserInfo];
    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbLogin == YES) {

        UserProfile *userProfile = [UserProfile getProfile:@"Facebook"];
        [self setFBUserInfo:userProfile];
    }
}

- (void)setFrameForIPhone6and6Plus {

    self.imgVwProfileImg.frame = CGRectMake((self.view.frame.size.width - 82)/2, self.imgVwProfileImg.frame.origin.y+35, 82, 82);
    self.imgVwBorderMask.frame = CGRectMake((self.view.frame.size.width - 84)/2, self.imgVwBorderMask.frame.origin.y+35, 84, 84);
    self.lblUserName.frame = CGRectMake((self.view.frame.size.width - self.lblUserName.frame.size.width)/2, self.imgVwBorderMask.frame.origin.y+self.imgVwBorderMask.frame.size.height+10, self.lblUserName.frame.size.width, 21);
    self.lblStatus.frame = CGRectMake((self.view.frame.size.width - self.lblStatus.frame.size.width)/2, self.lblUserName.frame.origin.y+self.lblUserName.frame.size.height+10, self.lblStatus.frame.size.width, self.lblStatus.frame.size.height);
}

#pragma mark - Get FB User Info
/**************************************************************************************************
 Function to get FB User Info
 **************************************************************************************************/

- (void)getFBUserInfo {

    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:ERROR_CONNECTING
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [Constant hideNetworkIndicator];
        return;
    }
    [Constant showNetworkIndicator];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

            // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        self.lblUserName.text = @"User is not login by settings.";
        self.lblUserName.hidden = NO;
        self.tbleVwFeeds.hidden = YES;
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

        self.tbleVwFeeds.hidden = NO;
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

#pragma mark - Get FB User friend list and own feeds
/**************************************************************************************************
 Function to get FB User friend list and satus
 **************************************************************************************************/

- (void)getProfileOfFB {

    [self getFbUserOwnFeeds];
    [self getFriendList];
}

#pragma mark - Get friend list
/**************************************************************************************************
 Function to get FB User Info
 **************************************************************************************************/

- (void)getFriendList {

    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^( FBRequestConnection *connection, id result,  NSError *error) {
                              if (error) {
                                      //  [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
                              } else {
                                  NSDictionary *dictResult = (NSDictionary *)result;
                                  NSString *strFriendCount = [[dictResult valueForKey:@"summary"]valueForKey:@"total_count"];
                                  self.lblUserFrdList.text = [NSString stringWithFormat:@"%@ friends", strFriendCount];
                              }
                        }];
}

#pragma mark-  Get user own post
/**************************************************************************************************
 Function to get FB User friend list and satus
 **************************************************************************************************/

- (void)getFbUserOwnFeeds {

    [FBRequestConnection startWithGraphPath:@"/me/feed"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^( FBRequestConnection *connection, id result,  NSError *error) {
                              if (error) {
                                  // [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
                              } else {

                                  NSArray *arryPost = [result objectForKey:@"data"];
                                  [self convertDataOfFBIntoModel:arryPost];
                              }
                          }];
}

#pragma mark - Convert array of FB into model class
/**************************************************************************************************
 Function to convert user data into data model
 **************************************************************************************************/

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    [self.arryOfFBUserFeed removeAllObjects];
    [self.arryTappedCell removeAllObjects];

    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            if ([[dictData valueForKey:@"story"] length] == 0) {

                NSDictionary *fromUser = [dictData objectForKey:@"from"];

                UserInfo *userInfo =[[UserInfo alloc]init];
                userInfo.userName = [fromUser valueForKey:@"name"];
                userInfo.fromId = [fromUser valueForKey:@"id"];
                userInfo.strUserPost = [dictData valueForKey:@"message"];
                userInfo.userSocialType = @"Facebook";
                if ([[dictData objectForKey:@"type"] isEqualToString:@"photo"]) {
                     userInfo.objectIdFB = [dictData objectForKey:@"object_id"];
                } else {
                    userInfo.objectIdFB = [dictData objectForKey:@"id"];
                }
                userInfo.type = [dictData objectForKey:@"type"];
                userInfo.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
                userInfo.postImg = [dictData valueForKey:@"picture"];
                [self.arryOfFBUserFeed addObject:userInfo];

                [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    [Constant hideNetworkIndicator];

     [self.tbleVwFeeds reloadData];
}

//#pragma mark - Convert profile into model class object
//
//- (void)convertFBUserInfoInModel:(NSDictionary *)dictInfo withProfileImg:(NSString *)strProfileImg {
//
//    UserProfile *userProfile = [[UserProfile alloc]init];
//    userProfile.userName = [dictInfo objectForKey:@"name"];
//    userProfile.userImg = [NSURL URLWithString:strProfileImg];
//
//    [self setFBUserInfo:userProfile];
//}

#pragma mark - Show user profilr info
/**************************************************************************************************
 Function to show user profile of fb user
 **************************************************************************************************/

- (void)setFBUserInfo:(UserProfile*)userProfile {

    self.lblUserName.text = userProfile.userName;
    NSString *strDescription = [NSString stringWithFormat:@"Hi!! I am %@.", userProfile.userName];
    self.lblStatus.text = strDescription;

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

#pragma mark - UITableView Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryOfFBUserFeed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tbleVwFeeds setHidden:NO];
    
 /*   NSString *cellIdentifier = @"cellFeeds";
    ProfileTableViewCustomCell *cell;

    cell = (ProfileTableViewCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    [cell setValueInSocialTableViewCustomCell: [self.arryOfFBUserFeed objectAtIndex:indexPath.row]];

    return cell;*/

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
    if (indexPath.row < self.arryTappedCell.count) {
        isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];
    }
    if(indexPath.row < [self.arryOfFBUserFeed count]){

            //  self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [self.arryOfFBUserFeed objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:NO withOtherTimeline:YES withProfile:YES ];
    } else {

        if (sharedAppDelegate.arryOfAllFeeds.count != 0) {

            [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:YES withOtherTimeline:YES withProfile:YES];
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        }
    }
    NSLog(@"%@",cell.touchCount);
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryOfFBUserFeed objectAtIndex:indexPath.row];

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

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {
     
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
        //[self.navController pushViewController:commentVw animated:YES];
   [[self navigationController] pushViewController:commentVw animated:YES];
}

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    [self.arrySelectedIndex removeAllObjects];

    [self.tbleVwFeeds beginUpdates];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPost inSection:0];
    [self.tbleVwFeeds reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwFeeds endUpdates];
    
    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    [self.arryTappedCell replaceObjectAtIndex:indexPost withObject:[NSNumber numberWithBool:NO]];

    indexPost = cellIndex;


    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwFeeds beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwFeeds reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwFeeds endUpdates];
}


#pragma mark - Show user profile
/**************************************************************************************************
 Function to show user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    NSString *strUserId = [NSString stringWithFormat:@"/%@",userInfo.fromId];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:strUserId
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {

                              } else {

                                  NSDictionary *dictProfile = (NSDictionary *)result;

                                  UserInfo *otherUserInfo = [[UserInfo alloc]init];
                                  otherUserInfo.userName = [dictProfile valueForKey:@"name"];
                                  otherUserInfo.fromId  = [dictProfile valueForKey:@"id"];
                                  otherUserInfo.userSocialType = @"Facebook";
                                  UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
                                  vwController.userInfo = otherUserInfo;
                                  [self.navigationController pushViewController:vwController animated:YES];
                              }
                          }];
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryOfFBUserFeed objectAtIndex:indexPath.row];

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

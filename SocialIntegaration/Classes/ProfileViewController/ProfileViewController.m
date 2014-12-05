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
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define TABLE_HEIGHT 385

@interface ProfileViewController () <CustomTableCellDelegate>

@property (nonatomic, strong) NSMutableArray *arryOfFBUserFeed;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;
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
    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [Constant showNetworkIndicator];

    [self.arryTappedCell removeAllObjects];
    [self.arrySelectedIndex removeAllObjects];
    //[self.tbleVwFeeds reloadData];

    [self getFBUserInfo];
    UserProfile *userProfile = [UserProfile getProfile:@"Facebook"];
    [self setFBUserInfo:userProfile];
}

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
                                  otherUserInfo.strUserName = [dictProfile valueForKey:@"name"];
                                  otherUserInfo.fromId  = [dictProfile valueForKey:@"id"];
                                  otherUserInfo.strUserSocialType = @"Facebook";
                                  UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                  ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
                                  vwController.userInfo = otherUserInfo;
                                  [self.navigationController pushViewController:vwController animated:YES];
                              }
                          }];
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
        [Constant hideNetworkIndicator];
        return;
    }

   /* [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];*/


    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
        [Constant hideNetworkIndicator];
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
    [self getFriendList];

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
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            if ([[dictData valueForKey:@"story"] length] == 0) {

                NSDictionary *fromUser = [dictData objectForKey:@"from"];

                UserInfo *userInfo =[[UserInfo alloc]init];
                userInfo.strUserName = [fromUser valueForKey:@"name"];
                userInfo.fromId = [fromUser valueForKey:@"id"];
                userInfo.strUserPost = [dictData valueForKey:@"message"];
                userInfo.strUserSocialType = @"Facebook";
                userInfo.objectIdFB = [dictData objectForKey:@"id"];
                userInfo.type = [dictData objectForKey:@"type"];
                userInfo.struserTime = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
                userInfo.strPostImg = [dictData valueForKey:@"picture"];
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

- (void)setFBUserInfo:(UserProfile*)userProfile {

    self.lblUserName.text = userProfile.userName;

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

#pragma mark - UITableViewDatasource

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

    BOOL isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];

    if(indexPath.row < [self.arryOfFBUserFeed count]){

            //  self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [self.arryOfFBUserFeed objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:isSelected withPagging:NO withOtherTimeline:YES];
    } else {

        if (sharedAppDelegate.arryOfAllFeeds.count != 0) {

            [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedCell:isSelected withPagging:YES withOtherTimeline:YES];
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        }
    }
    NSLog(@"%@",cell.touchCount);
    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [self.arryOfFBUserFeed objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    if (objUserInfo.strPostImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + TABLE_HEIGHT + 35);
            }
        }
        return(rect.size.height + TABLE_HEIGHT - 3);
    }

    for (NSString *index in self.arrySelectedIndex) {

        if (index.integerValue == indexPath.row) {
            return(rect.size.height + 90);
        }
    }
    return (rect.size.height + 65);//183 is height of other fixed content
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
    [self.tbleVwFeeds beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwFeeds reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwFeeds endUpdates];
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

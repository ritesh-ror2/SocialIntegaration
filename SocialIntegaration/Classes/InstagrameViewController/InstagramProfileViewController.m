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
#import "UserProfile+DatabaseHelper.h"
#import "Reachability.h"
#import "CustomTableCell.h"
#import "CommentViewController.h"
#import "Constant.h"
#import "UIFont+Helper.h"

@interface InstagramProfileViewController () <CustomTableCellDelegate> {

    int heightOfRowImg;
    int widthOfCommentLbl;
}

@property (nonatomic, strong) NSMutableArray *arryOfInstagrame;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;

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
    
    self.arryTappedCell = [[NSMutableArray alloc]init];
    self.arrySelectedIndex = [[NSMutableArray alloc]init];

    if(IS_IPHONE_6_IOS8 || IS_IPHONE_6P_IOS8) {

        [self setFrameForIPhone6and6Plus];
    }

    if (!IS_IPHONE5) {

        self.btnFollowing.hidden = YES;
        self.btnEdit.frame = self.btnFollowing.frame;
    }

    self.tbleVwInstagramPost.separatorColor = [UIColor lightGrayColor];
    heightOfRowImg = [Constant heightOfCellInTableVw];
    widthOfCommentLbl = [Constant widthOfCommentLblOfTimelineAndProfile];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self.arrySelectedIndex removeAllObjects];
    [self.arryTappedCell removeAllObjects];
    [self.tbleVwInstagramPost reloadData];

    for (NSString *cellSelected in sharedAppDelegate.arryOfInstagrame) {
        NSLog(@"%@", cellSelected);
        [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self.arryOfInstagrame removeAllObjects];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [[NSUserDefaults standardUserDefaults]setInteger:2 forKey:@"ProfilePage"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    self.arryOfInstagrame = [[NSMutableArray alloc]init];
    self.imgVwFBBackground.backgroundColor = [UIColor colorWithRed:66/256.0f green:106/256.0f blue:151/256.0f alpha:1.0];
    [self getInstagrameIntegration];
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


#pragma mark - Integrate instagrame
/**************************************************************************************************
 Function to integrate instagrame
 **************************************************************************************************/

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
    
    [Constant showNetworkIndicator];

    // here i can set accessToken received on previous login
    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;

    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];

    if (isInstagramUserLogin == NO) {

        [Constant hideNetworkIndicator];

        self.lblUserName.text = @"User is not login by settings.";
        self.tbleVwInstagramPost.hidden = YES;
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
    } else {

        UserProfile *userProfile = [UserProfile getProfile:@"Instagram"];
        [self showProfileData:userProfile];

        NSString *strMethod = [NSString stringWithFormat:@"users/%@/media/recent/",userProfile.userId];
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strMethod, @"method", nil]; //fetch feed
        [sharedAppDelegate.instagram requestWithParams:params
                                              delegate:self];
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

    self.tbleVwInstagramPost.hidden = NO;
    if ([[result objectForKey:@"data"] isKindOfClass:[NSArray class]]) {

        [self convertUserPostIntoModel:[result objectForKey:@"data"]];
        return;
    }
}

#pragma mark - Convert user post in to model class
/**************************************************************************************************
 Function to convert user post in to model class
 **************************************************************************************************/

- (void)convertUserPostIntoModel:(NSArray *)arryOfInstagrame1 {

    [self.arryOfInstagrame removeAllObjects];

    @autoreleasepool {

        for (NSDictionary *dictData in arryOfInstagrame1) {

            NSLog(@" instagrame %@", dictData);
            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"caption"];

            NSDictionary *dictUserInfo = [postUserDetailDict objectForKey:@"from"];
            userInfo.userName = [dictUserInfo valueForKey:@"username"];
            userInfo.fromId = [dictUserInfo valueForKey:@"id"];
            sharedAppDelegate.InstagramId = userInfo.fromId;
            userInfo.userProfileImg = [dictUserInfo valueForKey:@"profile_picture"];

            userInfo.strUserPost = [postUserDetailDict valueForKey:@"text"];
            NSString *strDate = [postUserDetailDict objectForKey:@"created_time"];

            NSTimeInterval interval = strDate.doubleValue;
            NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970: interval];
            userInfo.time = [Constant convertDateOFInstagram:convertedDate];

            NSDictionary *dictImage = [dictData objectForKey:@"images"];
            userInfo.postImg = [[dictImage valueForKey:@"low_resolution"]objectForKey:@"url"];

            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.userSocialType = @"Instagram";
            [self.arryOfInstagrame addObject:userInfo];

            NSLog(@"%@", self.arryOfInstagrame);
            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [Constant hideNetworkIndicator];
    [self.tbleVwInstagramPost reloadData];
}

#pragma mark - Show Profile data
/**************************************************************************************************
 Function to show user profile
 **************************************************************************************************/

- (void)showProfileData:(UserProfile *)userProfile {

    self.lblUserName.text = userProfile.userName;
    self.lblUserPost.text = userProfile.post;
    self.lblUserFollowes.text = userProfile.followers;
    self.lblUserFollowing.text = userProfile.following;
    self.lblStatus.text = userProfile.description;

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

#pragma mark - UITable View Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryOfInstagrame count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tbleVwInstagramPost setHidden:NO];
    NSString *cellIdentifier = @"cellIdentifier";
    CustomTableCell *cell;

    cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSArray *arryObjects;
    if (cell == nil) {

        arryObjects = [[NSBundle mainBundle]loadNibNamed:@"CustomTableCell" owner:nil options:nil];
        cell = [arryObjects objectAtIndex:0];
        cell.customCellDelegate = self;
    }
    return cell;
}

#pragma mark - UITable view Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfInstagrame.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfInstagrame count]-1) {
            return 44;
        }
    } else {
        return 0;
    }
    UserInfo *objUserInfo = [sharedAppDelegate.arryOfInstagrame objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(widthOfCommentLbl, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    if (objUserInfo.postImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + heightOfRowImg + 33);
            }
        }
        return(rect.size.height + heightOfRowImg - 3);
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
 Function to go to detail view to check like, comment favourite and etc
 **************************************************************************************************/

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

/**************************************************************************************************
 Function to increase cell height
 **************************************************************************************************/

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];
        //your code here
    if (self.arryTappedCell.count != 0) {
        if (isSelected == YES) {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
        } else {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
        }
    }
    [self.tbleVwInstagramPost beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwInstagramPost reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwInstagramPost endUpdates];
}

/**************************************************************************************************
 Function to go to user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

}

@end

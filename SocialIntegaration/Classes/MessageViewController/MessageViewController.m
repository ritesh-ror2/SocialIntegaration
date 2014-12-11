//
//  MessageViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 18/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "MessageViewController.h"
#import "UserComment.h"
#import "Constant.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import "MessageCustomCell.h"
#import "DetailMessageViewController.h"
#import "ShareCommentAndMessageViewController.h"
#import "HYCircleLoadingView.h"

@interface MessageViewController () <MessageCellTappedDelegate> {

    UserProfile *userProfile;
    NSString *strTitleUserName;
}

@property (nonatomic) BOOL isLoadingShow;
@property (nonatomic, strong) HYCircleLoadingView *loadingView;
@property (nonatomic, strong) NSMutableArray *arryOfFbMessage;

@end

@implementation MessageViewController

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

    userProfile = [UserProfile getProfile:@"Facebook"];

    UIBarButtonItem *barBtnProfile = [[UIBarButtonItem alloc]initWithCustomView:[self addUserImgAtLeftSide]];
    self.navigationItem.leftBarButtonItem = barBtnProfile;

        //right button
    UIBarButtonItem *barBtnEdit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];
    self.navigationItem.rightBarButtonItem = barBtnEdit;

    self.arryOfFbMessage = [[NSMutableArray alloc]init];

    sharedAppDelegate.isFirstTimeLaunch = NO;

    self.tbleVwFbMessage.hidden = YES;
    self.tbleVwFbMessage.alpha = 0;
    self.loadingView = [[HYCircleLoadingView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 70)/2, (self.view.frame.size.height - 100)/2, 70, 70)];
    [self.view addSubview:self.loadingView];
    [self.view bringSubviewToFront:self.loadingView];
    self.loadingView.hidden = YES;

    [self showAnimationView];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    if(self.isLoadingShow == NO) {
        [self showAnimationView];
    }
    [self showInboxMessage];
    self.navigationItem.title = @"Messages";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
}


- (void)showAnimationView {

    BOOL isFbLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if(isFbLogin == YES || isTwitter == YES) {

        self.isLoadingShow = YES;
        self.loadingView.hidden = NO;
        [self.loadingView startAnimation];
    }
}

#pragma mark - Compose message to post on fb and twitter
/**************************************************************************************************
 Function to compose message to post on fb and twitter
 **************************************************************************************************/

- (IBAction)composeMessage:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareCommentAndMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"sharecomment"];
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark - Compose message to post on fb and twitter
/**************************************************************************************************
 Function to show login user image in left side
 **************************************************************************************************/

- (UIImageView *)addUserImgAtLeftSide {

        //add mask image
    if (userProfile != nil) {

        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];
        UIImage *img = [UIImage imageWithData:image];
        UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
        UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
        imgVwProile.frame = CGRectMake(0, 0, 35, 35);
        return imgVwProile;
    }
    UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed: @"user-selected.png"] withMask:[UIImage imageNamed:@"list-mask.png"]];
    UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
    imgVwProile.frame = CGRectMake(0, 0, 35, 35);
    return imgVwProile;
}

#pragma mark - Show messages of inbox of fb
/**************************************************************************************************
 Function to show messages of inbox of fb
 **************************************************************************************************/

- (void)showInboxMessage {

    [Constant showNetworkIndicator];

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

            //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
        [Constant hideNetworkIndicator];
        return;
    }

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *readPermissions = @[@"read_mailbox"];
    [sharedAppDelegate.fbSession requestNewReadPermissions:readPermissions completionHandler:^(FBSession *session, NSError *error){

    sharedAppDelegate.fbSession = session;
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/me/inbox"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {
                                  NSLog(@"%@", [error localizedDescription]);
                              } else {
                                  [self convertDataOfFBIntoModel: [result objectForKey:@"data"]];
                              }
                          }];
    }];
}

#pragma mark - Convert array of FB into model class
/**************************************************************************************************
 Function to convert array of FB into model class
 **************************************************************************************************/

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    [self.arryOfFbMessage removeAllObjects];

    @autoreleasepool {

        for (NSDictionary *dictData1 in arryPost) {

            NSArray *commmetnt = [[dictData1 objectForKey:@"comments"]objectForKey:@"data"];

            NSMutableArray *arryMessages = [[NSMutableArray alloc]init];

            for (NSDictionary *dictData in commmetnt) {

                NSDictionary *fromUser = [dictData objectForKey:@"from"];
                UserComment *userComment =[[UserComment alloc]init];
                userComment.userName = [fromUser valueForKey:@"name"];
                userComment.fromId = [fromUser valueForKey:@"id"];
                userComment.userComment = [dictData valueForKey:@"message"];
                userComment.socialType = @"Facebook";
                userComment.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];

                [arryMessages addObject:userComment];
                NSArray *arryUsers = [[dictData1 valueForKey:@"to"]objectForKey:@"data"];
                for (NSDictionary *dictData in arryUsers) {

                    NSString *userId = [dictData valueForKey:@"id"];
                    if(![userId isEqualToString:userProfile.userId]) {

                        userComment.titleUserId = userId;
                        userComment.titleUserName = [dictData valueForKey:@"name"];

                        break;
                    }
                }   
            }
            [self.arryOfFbMessage addObject:arryMessages];
        }
    }
    [self.tbleVwFbMessage reloadData];

    if (self.arryOfFbMessage.count != 0) {
        [self showAnimationOfActivity];
    }
    [Constant hideNetworkIndicator];
}

- (void)showAnimationOfActivity {

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [self.tbleVwFbMessage setHidden:NO];
    [UIView setAnimationDuration:3.0];
    [self.tbleVwFbMessage setAlpha:1];
    self.tbleVwFbMessage.hidden = NO;
    [UIView commitAnimations];

    self.loadingView.hidden = YES;
    [self.loadingView stopAnimation];
}


#pragma mark - UITable View Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryOfFbMessage count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"cellMessage";
    MessageCustomCell *cell;

    cell = (MessageCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.delegate = self;
    [cell setMessageInTableViewCustomCell:[[self.arryOfFbMessage objectAtIndex:indexPath.row]objectAtIndex:0] withRowIndex:indexPath.row];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserComment *objUserComment = [[self.arryOfFbMessage objectAtIndex:indexPath.row]objectAtIndex:0];

    NSString *string = objUserComment.userComment;
    CGRect rect = [string boundingRectWithSize:CGSizeMake([Constant widthOfCommentLblOfTimelineAndProfile], 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    return (rect.size.height + 65);//183 is height of other fixed content
}

#pragma mark - Show all chat in detail
/**************************************************************************************************
 Function to show all chat in detail
 **************************************************************************************************/

- (void)showAllMessage:(NSInteger)cellIndex {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailMessage"];
    viewController.arryDetailMessage = [self.arryOfFbMessage objectAtIndex:cellIndex];
    NSLog(@"%@", [self.arryOfFbMessage objectAtIndex:cellIndex]);

    [[self navigationController] pushViewController:viewController animated:YES];
}

@end

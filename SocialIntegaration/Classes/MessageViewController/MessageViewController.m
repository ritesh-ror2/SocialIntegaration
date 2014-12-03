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

@interface MessageViewController () <MessageCellTappedDelegate> {

    UserProfile *userProfile;
    NSString *strTitleUserName;
}

@property (nonatomic, strong) NSMutableArray *arryOfFbMessage;

@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /*[self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES]; */

    [Constant showNetworkIndicator];

    userProfile = [UserProfile getProfile:@"Facebook"];

    UIBarButtonItem *barBtnProfile = [[UIBarButtonItem alloc]initWithCustomView:[self addUserImgAtRight]];
    self.navigationItem.leftBarButtonItem = barBtnProfile;

        //right button
    UIBarButtonItem *barBtnEdit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeMessage:)];
    self.navigationItem.rightBarButtonItem = barBtnEdit;

    self.arryOfFbMessage = [[NSMutableArray alloc]init];

    [self showInboxMessage];

//    if (IS_IOS7) {
//        [self.tbleVwFbMessage setSeparatorInset:UIEdgeInsetsZero];
//    }
    sharedAppDelegate.isFirstTimeLaunch = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    self.navigationItem.title = @"Messages";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};

}
- (IBAction)composeMessage:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShareCommentAndMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"sharecomment"];
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (UIImageView *)addUserImgAtRight {

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

- (void)showInboxMessage {

    BOOL isFbUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFbUserLogin == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_FB];
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
    [Constant hideNetworkIndicator];
    [self.tbleVwFbMessage reloadData];
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
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    return (rect.size.height + 65);//183 is height of other fixed content
}

- (void)showAllMessage:(NSInteger)cellIndex {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DetailMessageViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DetailMessage"];
    viewController.arryDetailMessage = [self.arryOfFbMessage objectAtIndex:cellIndex];
    NSLog(@"%@", [self.arryOfFbMessage objectAtIndex:cellIndex]);

    [[self navigationController] pushViewController:viewController animated:YES];
}

@end

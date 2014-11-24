//
//  TwitterFeedViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "TwitterFeedViewController.h"
#import "CustomTableCell.h"
#import "UserInfo.h"
#import "Constant.h"
#import "CommentViewController.h"
#import <Social/Social.h>
#import "ShowOtherUserProfileViewController.h"

@interface TwitterFeedViewController () <CustomTableCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tbleVwTwitter;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;

@end

@implementation TwitterFeedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self makeCustomViewForNavigationTitle];
    self.navController.navigationBar.translucent = NO;
    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self.arrySelectedIndex removeAllObjects];
    [self.arryTappedCell removeAllObjects];
    [self.tbleVwTwitter reloadData];

    self.navController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    if (sharedAppDelegate.arryOfTwittes.count == 0) {
        [Constant showAlert:@"Message" forMessage:ERROR_TWITTER_SETTING];
    }
    self.navItem.title = @"Twitter";

    [self.arryTappedCell removeAllObjects];
    for (NSString *cellSelected in sharedAppDelegate.arryOfTwittes) {
        NSLog(@"%@", cellSelected);
        [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    if ([userInfo.strUserSocialType isEqualToString:@"Facebook"]) {
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
    } if ([userInfo.strUserSocialType isEqualToString:@"Twitter"])  {

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
        vwController.userInfo = userInfo;
        [self.navigationController pushViewController:vwController animated:YES];
    }
}

- (void)getTweetFromTwitter:(UserInfo *)userData {

    //TWITTER_TIMELINE_URL
     NSDictionary* params = @{@"count": @"20", @"max_id": @"532861337668710400"};

    NSURL *requestURL = [NSURL URLWithString:TWITTER_TIMELINE_URL];
    SLRequest *timelineRequest = [SLRequest
                             requestForServiceType:SLServiceTypeTwitter
                             requestMethod:SLRequestMethodGET
                             URL:requestURL parameters:params];

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

              // [self convertDataOfTwitterIntoModel: arryTwitte];//convert into model class
      });
    }
    }];
}

- (void)makeCustomViewForNavigationTitle {

        // self.navItem.title = @"Twitter";
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    [self makeCustomViewForNavigationTitle];
    NSLog(@" ** count %icount ", sharedAppDelegate.arryOfTwittes.count);
    return [sharedAppDelegate.arryOfTwittes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"cellIdentifier";
    CustomTableCell *cell;

    cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSArray *arryObjects;
    if (cell == nil) {

        arryObjects = [[NSBundle mainBundle]loadNibNamed:@"CustomTableCell" owner:nil options:nil];
        cell = [arryObjects objectAtIndex:0];
        cell.customCellDelegate = self;
    }

    [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfTwittes objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [sharedAppDelegate.arryOfTwittes objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                       context:nil];

    if (objUserInfo.strPostImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + 190);
            }
        }
        return(rect.size.height + 160);
    }

    for (NSString *index in self.arrySelectedIndex) {

        if (index.integerValue == indexPath.row) {
            return(rect.size.height + 90);
        }
    }
    return (rect.size.height + 60);//183 is height of other fixed content
}

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    NSLog(@"****%@***", self.arrySelectedIndex);
        //your code here

    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwTwitter beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwTwitter reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwTwitter endUpdates];


        //  NSLog(@"%@", self.arryTappedCell);
    
}

@end

//
//  FacebookFeedViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "FacebookFeedViewController.h"
#import "CustomTableCell.h"
#import "CommentViewController.h"
#import "Constant.h"
#import "ShowOtherUserProfileViewController.h"

@interface FacebookFeedViewController () <CustomTableCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tbleVwFB;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;

@end

@implementation FacebookFeedViewController

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

    self.navController.navigationBar.translucent = NO;
    self.arryTappedCell = [[NSMutableArray alloc]init];
    self.arrySelectedIndex = [[NSMutableArray alloc]init];

    self.tbleVwFB.pagingEnabled= YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    self.navController.navigationBarHidden = NO;
    [self.arryTappedCell removeAllObjects];
    [self.arrySelectedIndex removeAllObjects];

    [self.tbleVwFB reloadData];
    for (NSString *cellSelected in sharedAppDelegate.arryOfFBNewsFeed) {
        NSLog(@"%@", cellSelected);
        [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
    }
}
- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    if (sharedAppDelegate.arryOfFBNewsFeed.count == 0) {
        [Constant showAlert:@"Message" forMessage:ERROR_FB_SETTING];
    }
    self.navItem.title = @"Facebook";
}

- (void)makeCustomViewForNavigationTitle {

        //self.navItem.title = @"Facebook";
}

#pragma mark - View to add image at left side

- (UIImageView *)addUserImgAtRight {

        //add mask image
    UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed: @"user-selected.png"] withMask:[UIImage imageNamed:@"list-mask.png"]];
    UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
    imgVwProile.frame = CGRectMake(0, 0, 35, 35);
    return imgVwProile;
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

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

     [self makeCustomViewForNavigationTitle];
    NSLog(@" ** count %icount ", sharedAppDelegate.arryOfFBNewsFeed.count);
    return [sharedAppDelegate.arryOfFBNewsFeed count];
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

    [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfFBNewsFeed objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *objUserInfo = [sharedAppDelegate.arryOfFBNewsFeed objectAtIndex:indexPath.row];

    NSLog(@"%@", objUserInfo.strPostImg);
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

- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc]
                              initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:nil];

//    UIActivityIndicatorView *activityIndicator =
//    [[UIActivityIndicatorView alloc]
//     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activityIndicator.center = cell.center;
//    [cell addSubview:activityIndicator];
//    [activityIndicator release];
//
//    [activityIndicator startAnimating];
//
//    cell.tag = kLoadingCellTag;

    return cell;
}

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    [self.arrySelectedIndex addObject:[NSNumber numberWithInt:cellIndex]];
        //your code here

    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwFB beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwFB reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwFB endUpdates];
}


@end

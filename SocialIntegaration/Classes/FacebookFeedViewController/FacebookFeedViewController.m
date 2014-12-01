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

@interface FacebookFeedViewController () <CustomTableCellDelegate, NSURLConnectionDelegate> {

    NSMutableData *fbData;
    NSMutableURLRequest *fbRequest;
    NSURLConnection *connetion;
}

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

    if (IS_IOS7) {
        [self.tbleVwFB setSeparatorInset:UIEdgeInsetsZero];
    }
    sharedAppDelegate.isFirstTimeLaunch = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    self.navController.navigationBarHidden = NO;
    self.noMoreResultsAvail = NO;
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
            // [Constant showAlert:@"Message" forMessage:ERROR_FB_SETTING];
    }
    self.navItem.title = @"Facebook";
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

    NSLog(@" ** count %icount ", sharedAppDelegate.arryOfFBNewsFeed.count);
    return [sharedAppDelegate.arryOfFBNewsFeed count]+1;
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

    if(indexPath.row < [sharedAppDelegate.arryOfFBNewsFeed count]){

        self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfFBNewsFeed objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:NO];
    } else {

        if (sharedAppDelegate.arryOfFBNewsFeed.count != 0) {

            if (self.noMoreResultsAvail == NO) {

                [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:YES];
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
                [self getMoreDataOfFeed];
            } else {
                self.noMoreResultsAvail = NO;
            }
        }
    }

        //limit=25&after
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfFBNewsFeed.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfFBNewsFeed count]-1) {
            return 44;
        }
    } else {
        return 0;
    }
    UserInfo *objUserInfo = [sharedAppDelegate.arryOfFBNewsFeed objectAtIndex:indexPath.row];

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

- (void)getMoreDataOfFeed {

    //Get more data of feed

    NSURL *fbUrl = [NSURL URLWithString:sharedAppDelegate.nextFbUrl];
    fbRequest = [[NSMutableURLRequest alloc]initWithURL:fbUrl];
    connetion = [[NSURLConnection alloc]initWithRequest:fbRequest delegate:self];
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    fbData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    [fbData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
        // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    self.noMoreResultsAvail = YES;
    id result = [NSJSONSerialization JSONObjectWithData:fbData options:kNilOptions error:nil];
    NSLog(@"%@", result);
    sharedAppDelegate.nextFbUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];
    [self convertDataOfFBIntoModel:[result objectForKey:@"data"]];
}

#pragma mark - Convert array of FB into model class

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *fromUser = [dictData objectForKey:@"from"];

            userInfo.strUserName = [fromUser valueForKey:@"name"];
            userInfo.fromId = [fromUser valueForKey:@"id"];
            userInfo.strUserPost = [dictData valueForKey:@"message"];
            userInfo.strUserSocialType = @"Facebook";
            userInfo.fbLike = [[dictData valueForKey:@"user_likes"] boolValue];
            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.struserTime = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
            userInfo.strPostImg = [dictData valueForKey:@"picture"];

            NSLog(@"*** %@", [dictData objectForKey:@"type"]);
            if (![[dictData objectForKey:@"type"] isEqualToString:@"video"] && ![[dictData objectForKey:@"type"] isEqualToString:@"photo"]) {
                userInfo.objectIdFB = [dictData valueForKey:@"id"];
            } else {
                userInfo.objectIdFB = [dictData valueForKey:@"object_id"];
            }

            userInfo.videoUrl = [dictData valueForKey:@"source"];
            [sharedAppDelegate.arryOfFBNewsFeed addObject:userInfo];

            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }
        [self.tbleVwFB reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
        // The request has failed for some reason!
    
}

@end

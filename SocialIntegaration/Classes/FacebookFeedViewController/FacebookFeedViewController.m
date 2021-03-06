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

    int heightOfRowImg;
    int widthOfCommentLbl;

    NSInteger indexPost;
}

@property (nonatomic, strong) IBOutlet UITableView *tbleVwFB;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;

@end

@implementation FacebookFeedViewController

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

    sharedAppDelegate.isFirstTimeLaunch = NO;

    heightOfRowImg = [Constant heightOfCellInTableVw];
    widthOfCommentLbl = [Constant widthOfCommentLblOfTimelineAndProfile];

    self.tbleVwFB.separatorColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navController.navigationBarHidden = NO;
    self.navController.navigationBar.translucent = NO;

    self.noMoreResultsAvail = NO;
    [self.arryTappedCell removeAllObjects];
    [self.arrySelectedIndex removeAllObjects];

    for (NSString *cellSelected in sharedAppDelegate.arryOfFBNewsFeed) {
        NSLog(@"%@", cellSelected);
        [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
    }
    [self.tbleVwFB reloadData];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    self.navController.navigationBar.hidden = NO;
    self.navController.navigationBar.translucent = NO;

    self.navItem.title = @"Facebook";
    [[NSUserDefaults standardUserDefaults]setInteger:self.index forKey:INDEX_OF_PAGE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

        //  NSLog(@" ** count %icount ", sharedAppDelegate.arryOfFBNewsFeed.count);
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

    BOOL isSelected = NO;
    if (self.arryTappedCell.count != 0 && indexPath.row < self.arryTappedCell.count) {
        isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];
    }

    if(indexPath.row < [sharedAppDelegate.arryOfFBNewsFeed count]){

        self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfFBNewsFeed objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:NO withOtherTimeline:YES withProfile:NO];
    } else {

        if (sharedAppDelegate.arryOfFBNewsFeed.count != 0) {

            if (self.noMoreResultsAvail == NO) {

                [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedCell:self.arrySelectedIndex withPagging:YES withOtherTimeline:YES withProfile:NO];
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
            return 60;
        }
    } else {
        return 0;
    }
    UserInfo *objUserInfo = [sharedAppDelegate.arryOfFBNewsFeed objectAtIndex:indexPath.row];

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

#pragma mark - Delegates of custom cell

/**************************************************************************************************
 Function to go to user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
    vwController.userInfo = userInfo;
    [self.navigationController pushViewController:vwController animated:YES];
}

/**************************************************************************************************
 Function to go to Detail view of see comment, give comment and like post etc
 **************************************************************************************************/

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentViewController *commentVw = [storyboard instantiateViewControllerWithIdentifier:@"CommentView"];
    commentVw.userInfo = objuserInfo;
    commentVw.postUserImg = imgName;
    [[self navigationController] pushViewController:commentVw animated:YES];
}

/**************************************************************************************************
 Function to increase height of table view
 **************************************************************************************************/

- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected {

    [self.arrySelectedIndex removeAllObjects];

    [self.tbleVwFB beginUpdates];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:indexPost inSection:0];
    [self.tbleVwFB reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwFB endUpdates];

    [self.arrySelectedIndex addObject:[NSNumber numberWithInteger:cellIndex]];

    [self.arryTappedCell replaceObjectAtIndex:indexPost withObject:[NSNumber numberWithBool:NO]];

    indexPost = cellIndex;

    if (self.arryTappedCell.count != 0) {
        if (isSelected == YES) {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
        } else {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
        }
    }
    [self.tbleVwFB beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwFB reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwFB endUpdates];
}

#pragma mark - Get more feeds of FB
/**************************************************************************************************
 Function to get more feeds of FB
 **************************************************************************************************/

- (void)getMoreDataOfFeed {

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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSLog(@"%@", error.description);
}

#pragma mark - Convert array of FB into model class
/**************************************************************************************************
 Function to convert data of FB into model class
 **************************************************************************************************/

- (void)convertDataOfFBIntoModel:(NSArray *)arryPost {

    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            UserInfo *userInfo =[[UserInfo alloc]init];

            NSDictionary *fromUser = [dictData objectForKey:@"from"];

            userInfo.userName = [fromUser valueForKey:@"name"];
            userInfo.fromId = [fromUser valueForKey:@"id"];
            userInfo.strUserPost = [dictData valueForKey:@"message"];
            userInfo.userSocialType = @"Facebook";
            userInfo.fbLike = [[dictData valueForKey:@"user_likes"] boolValue];
            userInfo.type = [dictData objectForKey:@"type"];
            userInfo.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];
            userInfo.postImg = [dictData valueForKey:@"picture"];

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

@end

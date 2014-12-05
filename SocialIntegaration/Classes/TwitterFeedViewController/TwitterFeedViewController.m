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

#define TABLE_HEIGHT 385

@interface TwitterFeedViewController () <CustomTableCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tbleVwTwitter;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic) int since_Id;
@property (nonatomic) int max_Id;
@property (nonatomic)BOOL noMoreResultsAvail;
@end

@implementation TwitterFeedViewController

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

    self.navController.navigationBar.translucent = NO;
    self.arrySelectedIndex = [[NSMutableArray alloc]init];
    self.arryTappedCell = [[NSMutableArray alloc]init];

    sharedAppDelegate.isFirstTimeLaunch = NO;

    if (sharedAppDelegate.arryOfTwittes.count != 0) {

        UserInfo *userInfo = [sharedAppDelegate.arryOfTwittes objectAtIndex:sharedAppDelegate.arryOfTwittes.count - 1];
        self.max_Id = userInfo.statusId.intValue;

        UserInfo *userInfoSince = [sharedAppDelegate.arryOfTwittes objectAtIndex:0];
        self.since_Id = userInfoSince.statusId.intValue;
    }
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
            // [Constant showAlert:@"Message" forMessage:ERROR_TWITTER_SETTING];
    }
    self.navItem.title = @"Twitter";
    [[NSUserDefaults standardUserDefaults]setInteger:self.index forKey:INDEX_OF_PAGE];
    [[NSUserDefaults standardUserDefaults]synchronize];

    [self.arryTappedCell removeAllObjects];
    if (sharedAppDelegate.arryOfTwittes.count > 0) {
        for (NSString *cellSelected in sharedAppDelegate.arryOfTwittes) {
            NSLog(@"%@", cellSelected);
            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load more tweets
/**************************************************************************************************
 Function to load more tweets
 **************************************************************************************************/

- (void)paggingInTwitter {

    //The max_id = top of tweets id list . since_id = bottom of tweets id list .
    //TWITTER_TIMELINE_URL since_id=24012619984051000&max_id=250126199840518145&result_type=recent&count=10

    NSDictionary* params = @{@"since_id":[NSNumber numberWithInt:self.since_Id], @"max_id":[NSNumber numberWithInt:self.max_Id], @"count":@"30"};

    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
    SLRequest *timelineRequest = [SLRequest
                             requestForServiceType:SLServiceTypeTwitter
                             requestMethod:SLRequestMethodGET
                             URL:requestURL parameters:params];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

        NSLog(@"%@ !#" , [error description]);
        id result = [NSJSONSerialization
                             JSONObjectWithData:responseData
                             options:NSJSONReadingMutableLeaves
                             error:&error];

        if (![result isKindOfClass:[NSDictionary class]]) {

            NSArray *arryTwitte = (NSArray *)result;
            [self convertDataOfTwitterIntoModel:arryTwitte];
        } else {
            NSLog(@"error %@", result);
        }
    }];
}


#pragma mark - Convert data of twitter in to model class
/**************************************************************************************************
 Function to convert data of Twitter into model class
 **************************************************************************************************/

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    self.noMoreResultsAvail = YES;
    BOOL isFirst = NO;

    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            //  NSLog(@"**%@", dictData); //14055301;
            NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];
            UserInfo *userInfo =[[UserInfo alloc]init];
            userInfo.strUserName = [postUserDetailDict valueForKey:@"name"];
            userInfo.fromId = [postUserDetailDict valueForKey:@"id"];
            userInfo.strUserImg = [postUserDetailDict valueForKey:@"profile_image_url"];

            NSArray *arryMedia = [[dictData objectForKey:@"extended_entities"] objectForKey:@"media"];

            if (arryMedia.count>0) {
                userInfo.strPostImg = [[arryMedia objectAtIndex:0] valueForKey:@"media_url"];
            }
            userInfo.strUserPost = [dictData valueForKey:@"text"];
            userInfo.strUserSocialType = @"Twitter";
            userInfo.type = [dictData objectForKey:@"type"];
            NSString *strDate = [Constant convertDateOfTwitterInDatabaseFormate:[dictData objectForKey:@"created_at"]];
            userInfo.struserTime = [Constant convertDateOFTwitter:strDate];
            userInfo.statusId = [dictData valueForKey:@"id"];
            userInfo.favourated = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"favorited"] integerValue]];
            userInfo.screenName = [postUserDetailDict valueForKey:@"screen_name"];
            userInfo.retweeted = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"retweeted"] integerValue]];
            userInfo.retweetCount = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"retweet_count"] integerValue]];
            userInfo.favourateCount = [NSString stringWithFormat:@"%i", [[dictData objectForKey:@"favorite_count"] integerValue]];
            userInfo.isFollowing = [[postUserDetailDict valueForKey:@"following"]boolValue];
            userInfo.dicOthertUser = postUserDetailDict;
            [sharedAppDelegate.arryOfTwittes addObject:userInfo];

            if (isFirst == NO) {

                self.max_Id = userInfo.statusId.intValue;
                isFirst = YES;
            }
            [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
        }
    }

    UserInfo *userInfoSince = [sharedAppDelegate.arryOfTwittes objectAtIndex:sharedAppDelegate.arryOfTwittes.count - 1];
    self.since_Id = userInfoSince.statusId.intValue;

    [self.tbleVwTwitter reloadData];
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@" ** count count %i ", sharedAppDelegate.arryOfTwittes.count);
    return [sharedAppDelegate.arryOfTwittes count]+1;
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

    BOOL isSelected  = NO;
    if (self.arryTappedCell.count != 0 && indexPath.row < self.arryTappedCell.count) {
       isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];
    }

    if(indexPath.row < [sharedAppDelegate.arryOfTwittes count]){

        [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfTwittes objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:isSelected withPagging:NO withOtherTimeline:YES];
    } else {

        if (sharedAppDelegate.arryOfAllFeeds.count != 0) {

            if (self.noMoreResultsAvail == NO) {

                [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedCell:isSelected withPagging:YES withOtherTimeline:YES];
                cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
                [self paggingInTwitter];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfTwittes.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfTwittes count]-1) {
            return 44;
        }
    } else {
        return 0;
    }
    UserInfo *objUserInfo = [sharedAppDelegate.arryOfTwittes objectAtIndex:indexPath.row];

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

#pragma mark - Custom cell Delegates

/**************************************************************************************************
 Function to go to user detail
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
    vwController.userInfo = userInfo;
    [self.navigationController pushViewController:vwController animated:YES];
}

/**************************************************************************************************
 Function to go to detail ciew to see comment, like , favourite etc
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

    NSLog(@"****%@***", self.arrySelectedIndex);

    if (self.arryTappedCell.count != 0) {
        if (isSelected == YES) {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
        } else {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
        }
    }
    [self.tbleVwTwitter beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwTwitter reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tbleVwTwitter endUpdates];
}

@end

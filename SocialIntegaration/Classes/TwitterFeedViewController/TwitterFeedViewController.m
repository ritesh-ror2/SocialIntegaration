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
@property (nonatomic) int since_Id;
@property (nonatomic) int max_Id;
@property (nonatomic)BOOL noMoreResultsAvail;
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

    if (IS_IOS7) {
        [self.tbleVwTwitter setSeparatorInset:UIEdgeInsetsZero];
    }

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

    [timelineRequest performRequestWithHandler:
    ^(NSData *responseData, NSHTTPURLResponse
    *urlResponse, NSError *error)
    {
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

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    self.noMoreResultsAvail = YES;

    BOOL isFirst = NO;
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            NSLog(@"**%@", dictData); //14055301;

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
            NSString *strDate = [self dateOfTwitter:[dictData objectForKey:@"created_at"]];
            userInfo.struserTime = [Constant convertDateOFTweeter:strDate];
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

                self.since_Id = userInfo.statusId.intValue;
                isFirst = YES;
            }
        }
    }

    UserInfo *userInfoSince = [sharedAppDelegate.arryOfTwittes objectAtIndex:sharedAppDelegate.arryOfTwittes.count - 1];
    self.max_Id = userInfoSince.statusId.intValue;

    [self.tbleVwTwitter reloadData];
}

#pragma mark - Convert date of twitter

- (NSString *)dateOfTwitter:(NSString *)createdDate {

    NSString *strDateInDatabaseFormate;

    NSString *strYear = [createdDate substringWithRange:NSMakeRange(createdDate.length-4, 4)];
    NSString *strMonth = [createdDate substringWithRange:NSMakeRange(4, 3)];
    NSString *strDate = [createdDate substringWithRange:NSMakeRange(8, 2)];

    NSString *strTime = [createdDate substringWithRange:NSMakeRange(11, 8)];//14

    NSString *finalDate = [NSString stringWithFormat:@"%@ %@ %@", strDate, strMonth, strYear];

    strDateInDatabaseFormate = [NSString stringWithFormat:@"%@ %@", finalDate, strTime];

    return strDateInDatabaseFormate;
}

- (void)makeCustomViewForNavigationTitle {

        // self.navItem.title = @"Twitter";
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    [self makeCustomViewForNavigationTitle];
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
    if(indexPath.row < [sharedAppDelegate.arryOfTwittes count]){

        // self.noMoreResultsAvail = NO;
        [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfTwittes objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:NO];
    } else {


        if (self.noMoreResultsAvail == NO) {

            [cell setValueInSocialTableViewCustomCell:nil forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:YES];
            cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
            [self paggingInTwitter];
        } else {

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
}

@end

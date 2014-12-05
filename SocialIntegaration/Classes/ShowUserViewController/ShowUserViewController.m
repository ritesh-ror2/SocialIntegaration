//
//  ShowUserViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShowUserViewController.h"
#import "Constant.h"
#import "UserInfo.h"
#import "SearchCustomCell.h"
#import "ShowOtherUserProfileViewController.h"

@interface ShowUserViewController () <UISearchDisplayDelegate, UISearchBarDelegate, IGRequestDelegate, IGSessionDelegate, SearchCustomDelegate>

@property (nonatomic, strong) NSMutableArray *arrySearchUserList;
@property (nonatomic, strong) NSString *strSearchText;
@end

@implementation ShowUserViewController

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
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.title = self.searchKeywordType;
    self.arrySearchUserList = [[NSMutableArray alloc]init];
    NSLog(@"%@", self.searchKeywordType);

    [self removeUISearchBarBackgroundInViewHierarchy:self.searchDisplayController.searchBar];
    UITextField *txfSearchField = [self.searchDisplayController.searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithWhite:.9 alpha:1.0];
    self.searchDisplayController.searchBar.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [self viewWillAppear:animated];

    if (self.strSearchText.length != 0) {

        if([self.socialType isEqualToString:@"Facebook"]) {
            [self searchFriendOnFb:self.strSearchText];
        } else if ([self.socialType isEqualToString:@"Twitter"]) {
            [self searchFriendOnTwitter:self.strSearchText];
        } else {
            [self searchOnInstagram:self.strSearchText];
        }
    }
}

#pragma mark - Remove background of search bar
/**************************************************************************************************
 Function to remove search bar background
 **************************************************************************************************/

- (void) removeUISearchBarBackgroundInViewHierarchy:(UIView *)view {
    
    for (UIView *subview in [view subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break; //To avoid an extra loop as there is only one UISearchBarBackground
        } else {
            [self removeUISearchBarBackgroundInViewHierarchy:subview];
        }
    }
}

#pragma mark - Search on instagram
/**************************************************************************************************
 Function to search on instagram
 **************************************************************************************************/

- (void)searchOnInstagram:(NSString *)strName {

    https://api.instagram.com/v1/users/search?q=jack&access_token=ACCESS-TOKEN

    sharedAppDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    sharedAppDelegate.instagram.sessionDelegate = self;

    BOOL isInstagramUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISINSTAGRAMLOGIN];
    if (isInstagramUserLogin == NO) {

        [Constant hideNetworkIndicator];
        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_INSTAGRAM];
    } else {

        if ([sharedAppDelegate.instagram isSessionValid]) {

            if ([self.searchKeywordType isEqualToString:@"User"]) {
                NSString *strUrl = [NSString stringWithFormat:@"users/search"];
                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strName, @"q", nil]; //fetch feed
                [sharedAppDelegate.instagram requestWithMethodName:strUrl params:params httpMethod:@"GET" delegate:self];
            } else {
                NSString *strUrl = [NSString stringWithFormat:@"tags/%@/media/recent", strName];//@"/tags/search"];

                NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strName, @"q", nil]; //fetch feed
                [sharedAppDelegate.instagram requestWithMethodName:strUrl params:params httpMethod:@"GET" delegate:self];
            }
        }
    }
}

#pragma - IGSessionDelegate

- (void)igDidLogin {

        // here i can store accessToken
    [[NSUserDefaults standardUserDefaults] setObject:sharedAppDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];

        // [self getInstagrameIntegration];
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

    NSArray *arry = [result objectForKey:@"data"];
    [self convertInstagramData:arry];
    NSLog(@"Instagram did load: %@", result);
    [Constant hideNetworkIndicator];
}

#pragma mark - Convert data of instagram
/**************************************************************************************************
 Function to convert data of instagram
 **************************************************************************************************/

- (void)convertInstagramData:(NSArray *)arry {

    for (NSDictionary *dictData in arry) {

        UserInfo *userInfo = [[UserInfo alloc]init];

        if ([self.searchKeywordType isEqualToString:@"User"]) {

            userInfo.strUserName = [dictData valueForKey:@"username"];
            userInfo.strUserImg = [dictData valueForKey:@"profile_picture"];
            userInfo.fromId = [dictData valueForKey:@"id"];
            userInfo.strUserSocialType = @"Instagram";
            userInfo.type = self.searchKeywordType;

            [self.arrySearchUserList addObject:userInfo];

        } else {

            NSDictionary *dictCaption = [dictData objectForKey:@"caption"];
            if ([dictData objectForKey:@"caption"] != [NSNull null]) {
                NSDictionary *dictUser = [dictCaption objectForKey:@"from"];
                userInfo.strUserName = [dictUser valueForKey:@"username"];
                userInfo.strUserImg = [dictUser valueForKey:@"profile_picture"];
                userInfo.fromId = [dictUser valueForKey:@"id"];
                userInfo.strUserPost = [dictCaption valueForKey:@"text"];

                userInfo.strUserSocialType = @"Instagram";
                userInfo.type = self.searchKeywordType;

                [self.arrySearchUserList addObject:userInfo];
            }
        }
    }
    [self.tbleVwUser reloadData];
}

#pragma mark - Search on twitter
/**************************************************************************************************
 Function to search on twitter
 **************************************************************************************************/

- (void)searchFriendOnTwitter:(NSString *)strKeyword {

        //  NSString *strKey = [strKeyword strin]
    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitter == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        return;
    }

    NSString *strKey;

    if ([self.searchKeywordType isEqualToString:@"user"]) {
        strKey = [NSString stringWithFormat:@"@%@",strKeyword];
    } else if ([self.searchKeywordType isEqualToString:@"Keyword"]) {
        strKey = strKeyword;
    } else {
        strKey = [NSString stringWithFormat:@"#%@",strKeyword];
    }

    NSDictionary *param = @{@"q":strKey};
    NSURL *requestURL = [NSURL URLWithString:TWITTER_SEACH];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:param];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error)
     {
       NSLog(@"%@ !#" , [error description]);
       id dataTwitte = [NSJSONSerialization
                        JSONObjectWithData:responseData
                        options:NSJSONReadingMutableLeaves
                        error:&error];

       if ([dataTwitte isKindOfClass:[NSDictionary class]]) {
           NSDictionary *dictData = (NSDictionary *)dataTwitte;
           if ([[dictData objectForKey:@"errors"]count] != 0) {

               NSLog(@"%@", [dictData objectForKey:@"errors"]);
               return ;
           }
       } else {
           NSArray *arryData1 = (NSArray *)dataTwitte;

           if (arryData1.count != 0) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self convertTwitterUsersListIntoModels:arryData1];
                   NSLog(@"success");
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{

                   [Constant hideNetworkIndicator];
                   [Constant showAlert:@"Message" forMessage:@"No match found."];
               });
           }
       }
     }];
}

#pragma mark - Convert data of twitter
/**************************************************************************************************
 Function to convert data of twitter
 **************************************************************************************************/

- (void)convertTwitterUsersListIntoModels:(NSArray *)arryUser {

     [self.arrySearchUserList removeAllObjects];

    for (NSDictionary *dictUser in arryUser) {
        
        UserInfo *userInfo = [[UserInfo alloc]init];
        userInfo.fromId = [NSString stringWithFormat:@"%lli",[[dictUser valueForKey:@"id"] longLongValue]];

        userInfo.strUserName = [dictUser valueForKey:@"name"];
        userInfo.isFollowing = [[dictUser valueForKey:@"username"] boolValue];
        userInfo.strUserImg = [dictUser valueForKey:@"profile_image_url"];
        userInfo.isFollowing = [[dictUser valueForKey:@"following"] boolValue];
        userInfo.strUserSocialType = @"Twitter";
        //set user profile
        NSString *strFollowers = [NSString stringWithFormat:@"%i",[[dictUser valueForKey:@"followers_count"] integerValue]];
         NSString *strTweet = [NSString stringWithFormat:@"%i",[[dictUser valueForKey:@"listed_count"] integerValue]];
        NSString *strFollowing = [NSString stringWithFormat:@"%i",[[dictUser valueForKey:@"friends_count"] integerValue]];
        NSDictionary *dictUserData = @{@"friends_count": strFollowing, @"followers_count":strFollowers, @"listed_count":strTweet, @"profile_image_url":userInfo.strUserImg, @"id":userInfo.fromId};
        userInfo.dicOthertUser = dictUserData;

        if ([self.searchKeywordType isEqualToString:@"Keyword"]) {
            userInfo.type = @"Keyword";
            userInfo.strUserPost =  [dictUser valueForKey:@"description"];
        } else {
            userInfo.type = @"User";
        }
    [self.arrySearchUserList addObject:userInfo];
    }

    [self.tbleVwUser reloadData];
    [Constant hideNetworkIndicator];
}

#pragma mark - Search on fb
/**************************************************************************************************
 Function to search on fb
 **************************************************************************************************/

- (void)searchFriendOnFb:(NSString *)strKeyword {

    NSDictionary *param = @{@"q": strKeyword,
                            @"type":@"user"};
    [FBRequestConnection startWithGraphPath:@"/search"
                                 parameters:param
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {

                                  NSLog(@"error %@", [error localizedDescription]);
                              } else {
                                  NSArray *arryComment = [result objectForKey:@"data"];
                                  [self convertFbUsersListIntoModels:arryComment];
                              }
                          }];
    
}

#pragma mark - Convert data of fb
/**************************************************************************************************
 Function to convert data of fb
 **************************************************************************************************/

- (void)convertFbUsersListIntoModels:(NSArray *)arryUser {

    for (NSDictionary *dictUser in arryUser) {

        UserInfo *userInfo = [[UserInfo alloc]init];
        userInfo.fromId = [NSString stringWithFormat:@"%lli",[[dictUser valueForKey:@"id"] longLongValue]];
        userInfo.strUserName = [dictUser valueForKey:@"name"];
        userInfo.strUserSocialType = @"Facebook";

        if ([self.searchKeywordType isEqualToString:@"Keyword"]) {
            userInfo.type = @"Keyword";
            userInfo.strUserPost =  [dictUser valueForKey:@"message"];
        } else {
            userInfo.type = @"User";
        }

        [self.arrySearchUserList addObject:userInfo];
    }
    [self.tbleVwUser reloadData];
    [Constant hideNetworkIndicator];
}

#pragma mark - UITable view Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrySearchUserList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"SeachUser";
    SearchCustomCell *cell;

    cell = (SearchCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    UserInfo *userInfo = [self.arrySearchUserList objectAtIndex:indexPath.row];
    [cell setSearchResultIntableView:userInfo];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITable view Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {

    UserInfo *userInfo = [self.arrySearchUserList objectAtIndex:indexPath.row];

    NSString *strPost = userInfo.strUserPost;

    if (strPost.length == 0) {
        return 47;
    }
    
    CGRect rect = [strPost boundingRectWithSize:CGSizeMake(250, 100)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];
    return (rect.size.height +30);
}

#pragma mark - Follow or unfollow friend
/**************************************************************************************************
 Function to follow or unfollow friend
 **************************************************************************************************/

- (void)followOrNotFollow:(UserInfo *)userInfo withTitle:(NSString *)follow {

    [self followOrNotFollowFriend:userInfo withFollowOrNot:follow];
}

- (void)followOrNotFollowFriend:(UserInfo *)userInfo withFollowOrNot:(NSString *)strFollow {

       if ([strFollow isEqualToString:@"Follow"]) {

        NSString *strUserId = [NSString stringWithFormat:@"%i",[userInfo.fromId integerValue]];
        NSDictionary *param = @{@"user_id": strUserId, @"follow":@"true"};
        NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                      URL:requestURL parameters:param];

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

                   NSLog(@"Success %@", arryTwitte);
               });
           }
         }];
        return;
    } else {

        NSString *strUserId = [NSString stringWithFormat:@"%i",[userInfo.fromId integerValue]];
        NSDictionary *param = @{@"user_id": strUserId};
        NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/destroy.json"];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodPOST
                                      URL:requestURL parameters:param];

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
                   NSLog(@"Success %@", arryTwitte);
               });
           }
         }];
        return;
    }

    [self.tbleVwUser reloadData];
}

#pragma mark - UIsearch view controller delegates

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self.arrySearchUserList removeAllObjects];

    NSLog(@"%@",searchBar.text);

    NSString *strTrim = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.view endEditing:YES];
    [searchBar canResignFirstResponder];

    self.strSearchText = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if([self.socialType isEqualToString:@"Facebook"]) {
        [self searchFriendOnFb:searchBar.text];
    } else if ([self.socialType isEqualToString:@"Twitter"]) {
        [self searchFriendOnTwitter:strTrim];
    } else {
        [self searchOnInstagram:strTrim];
    }
    [self.searchDisplayController setActive:NO];

    [Constant showNetworkIndicator];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

}

#pragma mark - User profile btn tapped

- (void)userProfileBtnTapped:(UserInfo *)userInfo {

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
    vwController.userInfo = userInfo;
    [self.navigationController pushViewController:vwController animated:YES];
}
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

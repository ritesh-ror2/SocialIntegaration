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

@interface ShowUserViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *arrySearchUserList;

@end

@implementation ShowUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"User";

    self.arrySearchUserList = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchFriendOnTwitter:(NSString *)strKeyword {

        //  NSString *strKey = [strKeyword strin]
    BOOL isTwitter = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitter == NO) {

        [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_TWITTER];
        return;
    }

    NSDictionary *param = @{@"q":strKeyword};
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/search.json"];
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

                   [sharedAppDelegate.spinner hide:YES];
                   [Constant showAlert:@"Message" forMessage:@"No notification in Twitter account."];
               });
           }
       }
     }];
}

- (void)convertTwitterUsersListIntoModels:(NSArray *)arryUser {

    for (NSDictionary *dictUser in arryUser) {

        UserInfo *userInfo = [[UserInfo alloc]init];
        userInfo.fromId = [NSString stringWithFormat:@"%lli",[[dictUser valueForKey:@"id"] longLongValue]];
        userInfo.strUserName = [dictUser valueForKey:@"name"];
        userInfo.strUserImg = [dictUser valueForKey:@"profile_image_url"];

        [self.arrySearchUserList addObject:userInfo];
    }
    [self.tbleVwUser reloadData];
    [sharedAppDelegate.spinner hide:YES];
}

- (void)searchFriendOnFb:(NSString *)strKeyword {

    NSString *type;
    if ([self.searchKeywordType isEqualToString:@"user"]) {
        type = @"user";
    } else {
        type = @"adkeyword";
    }
    NSDictionary *param = @{@"q": strKeyword,
                            @"type":type};
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

- (void)convertFbUsersListIntoModels:(NSArray *)arryUser {

    for (NSDictionary *dictUser in arryUser) {

        UserInfo *userInfo = [[UserInfo alloc]init];
        userInfo.fromId = [NSString stringWithFormat:@"%lli",[[dictUser valueForKey:@"id"] longLongValue]];
        userInfo.strUserName = [dictUser valueForKey:@"name"];

        [self.arrySearchUserList addObject:userInfo];
    }
    [self.tbleVwUser reloadData];
    [sharedAppDelegate.spinner hide:YES];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrySearchUserList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"SeachUser";
    UITableViewCell *cell;

    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    UserInfo *userInfo = [self.arrySearchUserList objectAtIndex:indexPath.row];
    cell.textLabel.text = userInfo.strUserName;
    return cell;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller  {

}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self.arrySearchUserList removeAllObjects];

    NSLog(@"%@",searchBar.text);

    NSString *strTrim = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.view endEditing:YES];
    [searchBar canResignFirstResponder];

    if([self.socialType isEqualToString:@"Facebook"]) {
        [self searchFriendOnFb:searchBar.text];
    } else if ([self.socialType isEqualToString:@"Twitter"]) {
        [self searchFriendOnTwitter:strTrim];
    }
    [self.searchDisplayController setActive:NO];

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

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

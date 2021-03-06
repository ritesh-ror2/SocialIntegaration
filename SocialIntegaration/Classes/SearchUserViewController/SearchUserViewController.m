//
//  SearchUserViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "SearchUserViewController.h"
#import "ShowUserViewController.h"
#import "UserProfile+DatabaseHelper.h"

@interface SearchUserViewController () {

    NSString *strSocialType;
    NSString *userNameFb;
    NSString *userNameTwitter;
    NSString *userNameInstagram;
}

@end

@implementation SearchUserViewController

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

    UserProfile *userProfiltFb = [UserProfile getProfile:@"Facebook"];
    userNameFb = userProfiltFb.userName;

    UserProfile *userProfiltTwitter = [UserProfile getProfile:@"Twitter"];
    userNameTwitter = userProfiltTwitter.userName;

    UserProfile *userProfiltInst = [UserProfile getProfile:@"Instagram"];
    userNameInstagram = userProfiltInst.userName;

    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title =  self.searchKeyword;
    [self removeUISearchBarBackgroundInViewHierarchy:self.searchDisplayController.searchBar];
    UITextField *txfSearchField = [self.searchDisplayController.searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithWhite:.9 alpha:1.0];
    self.searchDisplayController.searchBar.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0];

    self.tbleVwSearch.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
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

#pragma mark - UITable view Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    if(cell == nil) {

        cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"searchCell"];
    }

    if (indexPath.row == 0) {

        cell.textLabel.text = userNameFb;
        cell.detailTextLabel.text = @"Facebook";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0];

        cell.detailTextLabel.textColor = [UIColor colorWithRed:92/256.0f green:103/256.0f blue:159/256.0f alpha:1.0];
    }
    if (indexPath.row == 1) {

        cell.textLabel.text = userNameTwitter;
        cell.detailTextLabel.text = @"Twitter";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0];

        cell.detailTextLabel.textColor = [UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0];
    }
    if (indexPath.row == 2) {

        cell.textLabel.text = userNameInstagram;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
        cell.detailTextLabel.text = @"Instagram";
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0];

        cell.detailTextLabel.textColor = [UIColor colorWithRed:93/256.0f green:122/256.0f blue:154/256.0f alpha:1.0];
    }
    return cell;
}

#pragma mark - UITable view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        strSocialType = @"Facebook";
    } else if (indexPath.row == 1) {
        strSocialType = @"Twitter";
    } else {
        strSocialType = @"Instagram";
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowUserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUser"];
    viewController.searchKeywordType = self.searchKeyword;
    viewController.socialType = strSocialType;
    [[self navigationController] pushViewController:viewController animated:YES];
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

//
//  SearchViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchUserViewController.h"

@interface SearchViewController () {

    NSArray *array;
}

@end

@implementation SearchViewController

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

    array = @[@"User", @"Keyword", @"HashTag"];
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"Search";
    self.navigationItem.hidesBackButton = YES;

    self.searchBar.hidden = YES;
    [self removeUISearchBarBackgroundInViewHierarchy:self.searchDisplayController.searchBar];
    self.searchDisplayController.searchBar.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0];
    UITextField *txfSearchField = [self.searchDisplayController.searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor colorWithWhite:.9 alpha:1.0];

    self.tbleVwSearch.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

#pragma mark - Remove background of search bar
/**************************************************************************************************
 Function to remove search bar background
 **************************************************************************************************/

- (void)removeUISearchBarBackgroundInViewHierarchy:(UIView *)view {

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

    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    if(cell == nil) {

        cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"searchCell"];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];

    return cell;
}

#pragma mark - UITable view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchUserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchUser"];
    viewController.searchKeyword = [array objectAtIndex:indexPath.row];
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

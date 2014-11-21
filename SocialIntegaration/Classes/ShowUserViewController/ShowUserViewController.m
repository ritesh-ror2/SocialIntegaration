//
//  ShowUserViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShowUserViewController.h"

@interface ShowUserViewController () <UISearchDisplayDelegate>

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
    [self searchFriend];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)searchFriend {

    NSDictionary *param = @{@"q": @"Ronald",
                            @"type":@"user"};
    [FBRequestConnection startWithGraphPath:@"search"
                                 parameters:param
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {

                                  NSLog(@"frien %@", [error localizedDescription]);
                              } else {
                                  NSArray *arryComment = [result objectForKey:@"data"];
                                  [self showUserList:arryComment];
                              }
                          }];
    
}

- (void)showUserList:(NSArray *)arryUser {

    for (NSDictionary *dictUser in arryUser) {

        NSDictionary *ditUserProfile = [[NSDictionary alloc]init];
        NSString *userId = [NSString stringWithFormat:@"%lli",[[dictUser valueForKey:@"id"] longLongValue]];
        NSString *strName = [dictUser valueForKey:@"name"];
        [ditUserProfile setValue:userId forKey:@"id"];
        [ditUserProfile setValue:strName forKey:@"name"];

        [self.arrySearchUserList addObject:ditUserProfile];
    }
    [self.tbleVwUser reloadData];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arrySearchUserList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"DetailMessage";
    UITableViewCell *cell;

    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = [[self.arrySearchUserList objectAtIndex:indexPath.row]valueForKey:@"name"];

    return cell;
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

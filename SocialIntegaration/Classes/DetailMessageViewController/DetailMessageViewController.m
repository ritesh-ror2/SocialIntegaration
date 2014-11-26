//
//  DetailMessageViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "DetailMessageViewController.h"
#import "UserComment.h"
#import "DetailMessageShowCustomCellTableViewCell.h"
#import "UserProfile+DatabaseHelper.h"

@interface DetailMessageViewController () {

    UserProfile *userProfile;
}

@end

@implementation DetailMessageViewController

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

    UserComment * comment = [self.arryDetailMessage objectAtIndex:0];
    self.navigationItem.title = comment.titleUserName;
    userProfile = [UserProfile getProfile:@"Facebook"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITable View Datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryDetailMessage count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"DetailMessage";
    DetailMessageShowCustomCellTableViewCell *cell;

    cell = (DetailMessageShowCustomCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setDetailMessageOnTableView:[self.arryDetailMessage objectAtIndex:indexPath.row] withUserId:userProfile.userId];

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UserComment *objUserComment = [self.arryDetailMessage objectAtIndex:indexPath.row];

    if (objUserComment.userComment.length == 0) {
        return 0;
    }

    NSString *string = objUserComment.userComment;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(230, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    return (rect.size.height+25);//183 is height of other fixed content
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

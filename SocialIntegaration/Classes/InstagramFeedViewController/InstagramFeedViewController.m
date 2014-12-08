//
//  InstagramFeedViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "InstagramFeedViewController.h"
#import "CustomTableCell.h"
#import "Constant.h"
#import "CommentViewController.h"

#define TABLE_HEIGHT 385

@interface InstagramFeedViewController () <CustomTableCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tbleVwInstagram;

@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;

@end

@implementation InstagramFeedViewController

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
    self.arryTappedCell = [[NSMutableArray alloc]init];
    self.arrySelectedIndex = [[NSMutableArray alloc]init];

    sharedAppDelegate.isFirstTimeLaunch = NO;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    if (sharedAppDelegate.arryOfInstagrame.count == 0) {
        //[Constant showAlert:@"Message" forMessage:@"No Feeds."];
        return;
    }
    [self.arrySelectedIndex removeAllObjects];
    [self.arryTappedCell removeAllObjects];
    [self.tbleVwInstagram reloadData];
    self.navController.navigationBarHidden = NO;

    for (NSString *cellSelected in sharedAppDelegate.arryOfInstagrame) {
        NSLog(@"%@", cellSelected);
        [self.arryTappedCell addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    if (sharedAppDelegate.arryOfInstagrame.count == 0) {
            // [Constant showAlert:@"Message" forMessage:ERROR_INSTAGRAM];
    }
    self.navItem.title = @"Instagram";
    [[NSUserDefaults standardUserDefaults]setInteger:self.index forKey:INDEX_OF_PAGE];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@" ** count %lucount ", (unsigned long)sharedAppDelegate.arryOfInstagrame.count);
    
    return [sharedAppDelegate.arryOfInstagrame count];
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
    if (self.arryTappedCell.count != 0) {
        isSelected = [[self.arryTappedCell objectAtIndex:indexPath.row]boolValue];
    }

    [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfInstagrame objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedCell:isSelected withPagging:NO withOtherTimeline:YES];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfInstagrame.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfInstagrame count]-1) {
            return 60;
        }
    } else {
        return 0;
    }
    UserInfo *objUserInfo = [sharedAppDelegate.arryOfInstagrame objectAtIndex:indexPath.row];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    if (objUserInfo.postImg.length != 0) {

        for (NSString *index in self.arrySelectedIndex) {

            if (index.integerValue == indexPath.row) {
                return(rect.size.height + TABLE_HEIGHT + 33);
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
 Function to go to detail view to check like, comment favourite and etc
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
        //your code here
    if (self.arryTappedCell.count != 0) {
        if (isSelected == YES) {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
        } else {
            [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
        }
    }
    [self.tbleVwInstagram beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwInstagram reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwInstagram endUpdates];
}

/**************************************************************************************************
 Function to go to user profile
 **************************************************************************************************/

- (void)userProfileBtnTapped:(UserInfo*)userInfo {

//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
//    vwController.userInfo = userInfo;
//    [self.navigationController pushViewController:vwController animated:YES];
}

@end

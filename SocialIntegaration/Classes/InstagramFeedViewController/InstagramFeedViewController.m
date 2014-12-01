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

@interface InstagramFeedViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tbleVwInstagram;
@property (nonatomic, strong) NSMutableArray *arryTappedCell;
@property (nonatomic, strong) NSMutableArray *arrySelectedIndex;

@end

@implementation InstagramFeedViewController

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
        // self.navItem.title = @"Instagram";
    self.navController.navigationBar.translucent = NO;
    self.arryTappedCell = [[NSMutableArray alloc]init];
    self.arrySelectedIndex = [[NSMutableArray alloc]init];

    if (IS_IOS7) {
        [self.tbleVwInstagram setSeparatorInset:UIEdgeInsetsZero];
    }

    sharedAppDelegate.isFirstTimeLaunch = NO;
}

- (void)didReceiveMemoryWarning
{
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
    [self.arryTappedCell removeAllObjects];

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
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@" ** count %icount ", sharedAppDelegate.arryOfInstagrame.count);
    
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
    }

    [cell setValueInSocialTableViewCustomCell: [sharedAppDelegate.arryOfInstagrame objectAtIndex:indexPath.row]forRow:indexPath.row withSelectedIndexArray:self.arrySelectedIndex withSelectedCell:self.arryTappedCell withPagging:NO];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( sharedAppDelegate.arryOfInstagrame.count != 0) {
        if(indexPath.row > [sharedAppDelegate.arryOfInstagrame count]-1) {
            return 44;
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

    [self.arrySelectedIndex addObject:[NSNumber numberWithInt:cellIndex]];
        //your code here

    if (isSelected == YES) {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:YES] atIndex:cellIndex];
    } else {
        [self.arryTappedCell insertObject:[NSNumber numberWithBool:NO] atIndex:cellIndex];
    }
    [self.tbleVwInstagram beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    [self.tbleVwInstagram reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //your code here
    [self.tbleVwInstagram endUpdates];
}

@end

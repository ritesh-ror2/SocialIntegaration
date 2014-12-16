//
//  WelcomeViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 12/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIFont+Helper.h"
#import "HomePageViewController.h"

@interface WelcomeViewController () {
    HomePageViewController *vwControllerHome;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

        // Welcome View initialization
    welcomeScreenVw = [[WelcomeScreenView alloc]initWithFrame:self.view.frame withDelegate:self];
    [self.view addSubview:welcomeScreenVw];
    self.navigationController.navigationBarHidden = YES;
        // self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [welcomeScreenVw hidePageController:YES];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Welcome Screen view Delegate

- (void)welcomeScreen:(WelcomeScreenView*)welcomeScreen setLayoutInScrollVw:(CustomPageOfScrollView *)viewOfLayout withPageIndex:(NSInteger)pageIndex {
        //method to set layout on given view
    switch (pageIndex) {
        case 1:
            [self viewOfWelcome:viewOfLayout]; //add view on scroll view
            break;

        case 2:
            [self viewForWelcomeSceen1:viewOfLayout];// add view on scroll view
            break;

        case 3:
            [self viewForWelcomeSceen2:viewOfLayout]; // add view on scroll view
            break;

        case 4:
            [self viewForWelcomeSceen3:viewOfLayout]; // add view on scroll view
            break;

        default:
            break;
    }
}

- (NSInteger)numberOfPagesInWelcomeScreen:(WelcomeScreenView*)welcomeScreen { //method to pass number of welcome pages

    return 4;
}

- (BOOL)canMoveInCircleOfWelcomeScreen:(WelcomeScreenView *)welcomeScreen { //method to scroll welcome view

    return NO;
}

- (void)welcomeScreen:(WelcomeScreenView *)welcomeScreen didSelectPagewithIndexNumber:(NSInteger)pageIndex withSubviewComponent:(UIView *)subview { //method to get event after touvh on view

    NSLog(@"PageIndex = %li", (long)pageIndex);
    NSLog(@"%@", subview);

        //Get View at page index
    CustomPageOfScrollView *vwOfIndex = [welcomeScreenVw getViewFromScrollViewatIndexPage:pageIndex];
    NSLog(@"%@", vwOfIndex);
}

- (void)viewOfWelcome:(UIView *)welcomeVw {

    [welcomeScreenVw setbackgroundColor];

    UIImage *imgScroll1 = [UIImage imageNamed:@"home.png"];

    UIImageView *imgVwOfWelcomeImg = [[UIImageView alloc]init];
    imgVwOfWelcomeImg.frame = CGRectMake((self.view.frame.size.width - imgScroll1.size.width)/2, (self.view.frame.size.height - imgScroll1.size.height)/2, imgScroll1.size.width, imgScroll1.size.height);
    imgVwOfWelcomeImg.image = imgScroll1;
    imgVwOfWelcomeImg.contentMode = UIViewContentModeScaleAspectFill;

    UILabel *lblTitle1 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 140)/2, self.view.frame.size.height - 70, 140, 25)];
    lblTitle1.numberOfLines = 0;
    lblTitle1.textColor = [UIColor colorWithRed:103/256.0f green:188/256.0f blue:246/256.0f alpha:1.0];
    lblTitle1.font = [UIFont fontWithRegularWithSize:21];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:@"Swipe to begin"];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17] range:NSMakeRange(0, 5)];
    lblTitle1.attributedText = attrStr;
    lblTitle1.textAlignment = NSTextAlignmentCenter;

    [welcomeVw addSubview:lblTitle1];
    welcomeVw.backgroundColor = [UIColor whiteColor];

    [welcomeVw addSubview:imgVwOfWelcomeImg];
}

- (void)viewForWelcomeSceen1:(UIView*)welcomeVw {

    //Locally image view for scroll view images

    [welcomeScreenVw setbackgroundColor];
    UILabel *lblTitle1 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 310)/2, 60, 310, 25)];
    lblTitle1.numberOfLines = 0;
    lblTitle1.textColor = [UIColor darkGrayColor];
    lblTitle1.textAlignment = NSTextAlignmentCenter;
    lblTitle1.font = [UIFont fontWithLightWithSize:21];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:@"One sorts your timeline by time."];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:21] range:NSMakeRange(attrStr.length - 5,5)];
    lblTitle1.attributedText = attrStr;
     [welcomeVw addSubview:lblTitle1];

    UILabel *lblTitle2 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 250)/2, 100, 250, 50)];
    lblTitle2.numberOfLines = 0;
    lblTitle2.textAlignment = NSTextAlignmentCenter;
    lblTitle2.textColor = [UIColor darkGrayColor];
    lblTitle2.font = [UIFont fontWithLightWithSize:21];
    lblTitle2.text = @"The latest posts are close to top.";
     [welcomeVw addSubview:lblTitle2];

    UIImage *imgScroll1;
    if (IS_IPHONE5) {
        imgScroll1 = [UIImage imageNamed:@"Setup2.png"];
    } else {
        imgScroll1 = [UIImage imageNamed:@"Setup2_iPhone6@2x.png"];
    }
    UIImageView *imgVwOfWelcomeImg = [[UIImageView alloc]init];
    imgVwOfWelcomeImg.frame = CGRectMake((self.view.frame.size.width - imgScroll1.size.width)/2, self.view.frame.size.height - imgScroll1.size.height, imgScroll1.size.width, imgScroll1.size.height);
    imgVwOfWelcomeImg.image = imgScroll1;
    imgVwOfWelcomeImg.contentMode = UIViewContentModeScaleAspectFit;
    [welcomeVw addSubview:imgVwOfWelcomeImg];

    welcomeVw.backgroundColor = [UIColor colorWithRed:245/256.0f green:245/256.0f blue:245/256.0f alpha:1.0];
}

- (void)viewForWelcomeSceen2:(UIView*)welcomeVw {

    [welcomeScreenVw setbackgroundColor];

    UILabel *lblTitle1 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 310)/2, 60, 310, 25)];
    lblTitle1.numberOfLines = 0;
    lblTitle1.textColor = [UIColor darkGrayColor];
    lblTitle1.font = [UIFont fontWithLightWithSize:21];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:@"Swipe right to hide a post."];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:21] range:NSMakeRange(0, 5)];
    lblTitle1.attributedText = attrStr;
    lblTitle1.textAlignment = NSTextAlignmentCenter;
    [welcomeVw addSubview:lblTitle1];

    UILabel *lblTitle2 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, 100, 280, 50)];
    lblTitle2.numberOfLines = 0;
    lblTitle2.textColor = [UIColor darkGrayColor];
    lblTitle2.font = [UIFont fontWithLightWithSize:21];
    lblTitle2.textAlignment = NSTextAlignmentCenter;
    lblTitle2.text = @"The post won't be deleted just hidden from your timeline.";
    [welcomeVw addSubview:lblTitle2];

    UIImage *imgScroll1;
    if (IS_IPHONE5) {
        imgScroll1 = [UIImage imageNamed:@"Setup3.png"];
    } else {
        imgScroll1 = [UIImage imageNamed:@"Setup3_iPhone6@2x.png"];
    }
    UIImageView *imgVwOfWelcomeImg = [[UIImageView alloc]init];
    imgVwOfWelcomeImg.frame = CGRectMake((self.view.frame.size.width - imgScroll1.size.width)/2, self.view.frame.size.height - imgScroll1.size.height, imgScroll1.size.width, imgScroll1.size.height);
    imgVwOfWelcomeImg.image = imgScroll1;
    imgVwOfWelcomeImg.contentMode = UIViewContentModeScaleAspectFit;
    [welcomeVw addSubview:imgVwOfWelcomeImg];

    welcomeVw.backgroundColor = [UIColor colorWithRed:245/256.0f green:245/256.0f blue:245/256.0f alpha:1.0];
}

- (void)viewForWelcomeSceen3:(UIView*)welcomeVw {

    welcomeScreenVw.backgroundColor = [UIColor colorWithRed:245/256.0f green:245/256.0f blue:245/256.0f alpha:1.0];

    UILabel *lblTitle1 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 310)/2, 60, 310, 25)];
    lblTitle1.numberOfLines = 0;
    lblTitle1.textColor = [UIColor darkGrayColor];
    lblTitle1.font = [UIFont fontWithLightWithSize:21];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:@"Swipe through your networks."];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17] range:NSMakeRange(0, 5)];
    lblTitle1.attributedText = attrStr;
    lblTitle1.textAlignment = NSTextAlignmentCenter;
    [welcomeVw addSubview:lblTitle1];

    UILabel *lblTitle2 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 260)/2, 100, 260, 50)];
    lblTitle2.numberOfLines = 0;
    lblTitle2.textColor = [UIColor darkGrayColor];
    lblTitle2.font = [UIFont fontWithLightWithSize:21];
    lblTitle2.text = @"View just Facebook posts, just Twitter or just Instagram.";
    lblTitle2.textAlignment = NSTextAlignmentCenter;

    [welcomeVw addSubview:lblTitle2];

    UIImage *imgScroll1;
    if (IS_IPHONE5) {
        imgScroll1 = [UIImage imageNamed:@"Setup4.png"];
    } else {
        imgScroll1 = [UIImage imageNamed:@"Setup4_iPhone6@2x.png"];
    }
    UIImageView *imgVwOfWelcomeImg = [[UIImageView alloc]init];
    imgVwOfWelcomeImg.frame = CGRectMake((self.view.frame.size.width - imgScroll1.size.width)/2, self.view.frame.size.height - imgScroll1.size.height, imgScroll1.size.width, imgScroll1.size.height);
    imgVwOfWelcomeImg.image = imgScroll1;
    imgVwOfWelcomeImg.contentMode = UIViewContentModeScaleAspectFit;
    [welcomeVw addSubview:imgVwOfWelcomeImg];

    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setTitle:@"Login" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnLogin.frame = CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 50 , 70, 44);
    //[btnLogin setBackgroundColor:[UIColor blackColor]];
    [btnLogin addTarget:self action:@selector(loginBtnTapp:) forControlEvents:UIControlEventTouchUpInside];
    [welcomeVw addSubview:btnLogin];

    welcomeVw.backgroundColor = [UIColor colorWithRed:245/256.0f green:245/256.0f blue:245/256.0f alpha:1.0];
}

- (void)loginBtnTapp:(id)sender{

    [self performSegueWithIdentifier:@"home" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"home"]){
        vwControllerHome = [segue destinationViewController];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

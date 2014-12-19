//
//  PageControllerCustomClass.m
//  SocialIntegaration
//
//  Created by GrepRuby on 27/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "PageControllerCustomClass.h"

@interface PageControllerCustomClass ()

@end

@implementation PageControllerCustomClass

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

    self.navigationController.navigationBar.hidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set page controller in navigation controller

- (void)setupNavigationPageControl{

    UINavigationController *navController = self.navigationController;

    navController.navigationBar.barTintColor = [UIColor whiteColor];

    CGSize navBarSize = navController.navigationBar.bounds.size;
    CGPoint origin = CGPointMake((navBarSize.width-60)/2, (navBarSize.height/2));

    self.navigationPageControl = [[FXPageControl alloc]initWithFrame:CGRectMake(origin.x, origin.y, 60, 30)];
        //[[CustomPageControll alloc] initWithFrame:CGRectMake(origin.x, origin.y, 60, 30)];//(origin.x, origin.y,0, 0)];

    self.navigationPageControl.defersCurrentPageDisplay = YES;
    self.navigationPageControl.selectedDotShape = FXPageControlDotShapeCircle;
    self.navigationPageControl.selectedDotSize = 5.0;
    self.navigationPageControl.dotSize = 5.0;
    self.navigationPageControl.numberOfPages = 4;
    self.navigationPageControl.dotSpacing = 5.0;
    self.navigationPageControl.wrapEnabled = YES;

    self.navigationPageControl.hidden = NO;
    self.navigationPageControl.backgroundColor = [UIColor clearColor];
    [navController.navigationBar addSubview:self.navigationPageControl];
}

- (void)setupNavigationPageControlProfile {

    [self setupNavigationPageControl];

    self.navigationPageControl.selectedDotColor = [UIColor whiteColor];
    self.navigationPageControl.dotColor = [UIColor colorWithWhite:1.0 alpha:0.4];
}

- (void)setupNavigationPageControlFeeds{

    [self setupNavigationPageControl];

    self.navigationPageControl.selectedDotColor = [UIColor blackColor];
    self.navigationPageControl.dotColor = [UIColor colorWithRed:245/256.0f green:245/256.0f blue:245/256.0f alpha:245/256.0f];
}

#pragma mark - Set page number

- (void)setPageNumber:(int)pageNumber {

    self.navigationPageControl.currentPage = pageNumber;
}

#pragma mark - Configure page controller in navigation controller

- (void)configureNavigationPageControlWithPageControl:(FXPageControl*) pageControl{
    self.origanalPageControl = pageControl;
    if(self.origanalPageControl){
        self.navigationPageControl.numberOfPages = self.origanalPageControl.numberOfPages;
        [self.origanalPageControl removeFromSuperview];
    }
}

- (void)autoConfigureNavigationPageControlWithPageViewController:(UIPageViewController*) pageViewController{

    NSArray *subviews = pageViewController.view.subviews;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            self.origanalPageControl = (FXPageControl *)[subviews objectAtIndex:i];
        }
    }
    if(self.origanalPageControl){
        self.navigationPageControl.numberOfPages = self.origanalPageControl.numberOfPages;
        [self.origanalPageControl removeFromSuperview];
    }
}

#pragma mark - Set curent page

- (void)updateNavigationPageControl{

    if(self.origanalPageControl){
        self.navigationPageControl.currentPage = self.origanalPageControl.currentPage;
    }
}

#pragma mark - Set page controller frame

- (void)setupNavigationPageControlFrame:(UIView *)vwPageController {

    [vwPageController addSubview:self.navigationPageControl];
}

@end

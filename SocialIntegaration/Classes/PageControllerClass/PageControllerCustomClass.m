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
    CGPoint origin = CGPointMake(navBarSize.width/2, (navBarSize.height/3)*2.5 );

    self.navigationPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(origin.x, origin.y,0, 0)];
    self.navigationPageControl.hidden = NO;
    self.navigationPageControl.backgroundColor = [UIColor whiteColor];
    [navController.navigationBar addSubview:self.navigationPageControl];
}

#pragma mark - Set page number

- (void)setPageNumber:(int)pageNumber {

    self.navigationPageControl.currentPage = pageNumber;
}

#pragma mark - Configure page controller in navigation controller

- (void)configureNavigationPageControlWithPageControl:(UIPageControl*) pageControl{
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
            self.origanalPageControl = (UIPageControl *)[subviews objectAtIndex:i];
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

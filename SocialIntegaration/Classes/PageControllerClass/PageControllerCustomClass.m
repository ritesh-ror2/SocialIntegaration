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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigationPageControl{

    UINavigationController *navController = self.navigationController;

    navController.navigationBar.barTintColor = [UIColor whiteColor];

    CGSize navBarSize = navController.navigationBar.bounds.size;
    CGPoint origin = CGPointMake(navBarSize.width/2, (navBarSize.height/3)*2.5 );

    self.navigationPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(origin.x, origin.y,0, 0)];
    self.navigationPageControl.hidden = NO;
    self.navigationPageControl.backgroundColor = [UIColor whiteColor];
    [navController.navigationBar addSubview:self.navigationPageControl];
}

- (void)setPageNumber:(int)pageNumber {
    self.navigationPageControl.currentPage = pageNumber;
}

-(void)configureNavigationPageControlWithPageControl:(UIPageControl*) pageControl{
    self.origanalPageControl = pageControl;
    if(self.origanalPageControl){
        self.navigationPageControl.numberOfPages = self.origanalPageControl.numberOfPages;
        [self.origanalPageControl removeFromSuperview];
    }
}

-(void)autoConfigureNavigationPageControlWithPageViewController:(UIPageViewController*) pageViewController{
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

-(void)updateNavigationPageControl{
    if(self.origanalPageControl){
        self.navigationPageControl.currentPage = self.origanalPageControl.currentPage;
    }
}

- (void)setupNavigationPageControlFrame:(UIView *)vwPageController {

    [vwPageController addSubview:self.navigationPageControl];
}

@end

//
//  ViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "StatrtPageControllViewController.h"
#import "ProfileViewController.h"
#import "TwitterProfileViewController.h"
#import "InstagramProfileViewController.h"

@interface StatrtPageControllViewController ()

@end

@implementation StatrtPageControllViewController

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    id startingViewController = [self viewControllerAtIndex:1];
    ProfileViewController *vwController = (ProfileViewController *)startingViewController;

    dispatch_async (dispatch_get_main_queue(), ^(void) {

         NSArray *viewControllers = @[vwController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            // Change the size of page view controller
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        [self.pageViewController becomeFirstResponder];
    });
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    [self performSelector:@selector(showPageControlOfprofile) withObject:nil afterDelay:0.1];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)showPageControlOfprofile {

        //>>>>>>> 8bb65de51a914a175ec2eb603298f2f67e902f45
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];

    [self setupNavigationPageControl];

    UIView *vwPageControl;
     if (!IS_IPHONE5) {
          vwPageControl = [[UIView alloc]initWithFrame:CGRectMake(0, 200, 60, 40)];
     } else {
         vwPageControl = [[UIView alloc]initWithFrame:CGRectMake(0, 230, 60, 40)];
     }
    [self.view addSubview:vwPageControl];
    [self.view bringSubviewToFront:vwPageControl];

    [self setupNavigationPageControlFrame:vwPageControl];

    [self autoConfigureNavigationPageControlWithPageViewController:self.pageViewController];

    [self performSelector:@selector(setPageOfPageVwController) withObject:nil afterDelay:0.1];
}

- (void)setPageOfPageVwController {

    int pageIndex = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"ProfilePage"];
    [self setPageNumber:pageIndex];
}

#pragma mark - View controller array

- (id)viewControllerAtIndex:(NSUInteger)index {

    if (index == 1) { //Fb Profile

        ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
        profileViewController.index = index;
        return profileViewController;
    }

    if (index == 2) { //Twitter Profile

        TwitterProfileViewController *tweeterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterProfile"];
        tweeterViewController.index = index;
        return tweeterViewController;
    }

    if (index == 3) { // Instagrame Profile

        InstagramProfileViewController *instagramViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InstagramProfile"];
        instagramViewController.index = index;
        return instagramViewController;
    }
    return nil;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    [self updateNavigationPageControl];

    NSUInteger pageIndex;

    if ([viewController isKindOfClass:[ProfileViewController class]]) {
        pageIndex = ((ProfileViewController*) viewController).index;
    } else if ([viewController isKindOfClass:[TwitterProfileViewController class]]) {
        pageIndex = ((TwitterProfileViewController*) viewController).index;
    } else {
        pageIndex = ((InstagramProfileViewController*) viewController).index;
    }

    if ((pageIndex == 0) || (pageIndex == NSNotFound)) {
        return nil;
    }

    pageIndex--;
    return [self viewControllerAtIndex:pageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    [self updateNavigationPageControl];

    NSUInteger pageIndex;

    if ([viewController isKindOfClass:[ProfileViewController class]]) {
        pageIndex = ((ProfileViewController*) viewController).index;
    } else if ([viewController isKindOfClass:[TwitterProfileViewController class]]) {
        pageIndex = ((TwitterProfileViewController*) viewController).index;
    } else {
        pageIndex = ((InstagramProfileViewController*) viewController).index;
    }

    if ((pageIndex == 0) || (pageIndex == NSNotFound)) {
        return nil;
    }

    pageIndex++;
    return [self viewControllerAtIndex:pageIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {

    return 3;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

@end

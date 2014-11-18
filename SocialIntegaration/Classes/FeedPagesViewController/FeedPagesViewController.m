//
//  FeedPagesViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "FeedPagesViewController.h"

@interface FeedPagesViewController ()

@end

@implementation FeedPagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];

        // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedPageView"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    id startingViewController = [self viewControllerAtIndex:0];
    ViewController *vwController = (ViewController *)startingViewController;
    NSArray *viewControllers = @[vwController];

    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

        // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-36);

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    [self.pageViewController becomeFirstResponder];

    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        //  self.navigationController.title = @"Timeline";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View controller array

- (id)viewControllerAtIndex:(NSUInteger)index {

    if (index == 0) { //Fb Profile

        ViewController *timelineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TimelineFeeds"];
        timelineViewController.index = index;
        timelineViewController.navItem = self.navigationItem;
        timelineViewController.navController = self.navigationController;
        return timelineViewController;
    }

    if (index == 1) { //Twitter Profile

        FacebookFeedViewController *fbFeedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FBFeeds"];
        fbFeedViewController.index = index;
        fbFeedViewController.navItem = self.navigationItem;
        fbFeedViewController.navController = self.navigationController;
        return fbFeedViewController;
    }

    if (index == 2) { // Instagrame Profile

        TwitterFeedViewController *twitterFeedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TwitterFeeds"];
        twitterFeedViewController.index = index;
        twitterFeedViewController.navController = self.navigationController;
        twitterFeedViewController.navItem = self.navigationItem;

        return twitterFeedViewController;
    }

    if (index == 3) { // Instagrame Profile

        InstagramFeedViewController *instagramFeedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InstagramFeeds"];
        instagramFeedViewController.index = index;
        instagramFeedViewController.navController = self.navigationController;
        instagramFeedViewController.navItem = self.navigationItem;
        return instagramFeedViewController;
    }
    return nil;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    NSUInteger pageIndex;

    if ([viewController isKindOfClass:[ViewController class]]) {
        pageIndex = ((ViewController*) viewController).index;
    } else if ([viewController isKindOfClass:[FacebookFeedViewController class]]) {
        pageIndex = ((FacebookFeedViewController*) viewController).index;
    } else if ([viewController isKindOfClass:[TwitterFeedViewController class]]) {
        pageIndex = ((TwitterFeedViewController*) viewController).index;
    } else {
        pageIndex = ((InstagramFeedViewController*) viewController).index;
    }

    if ((pageIndex == 0) || (pageIndex == NSNotFound)) {
        return nil;
    }

    pageIndex--;
    return [self viewControllerAtIndex:pageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    NSUInteger pageIndex;

    if ([viewController isKindOfClass:[ViewController class]]) {
        pageIndex = ((ViewController*) viewController).index;
    } else if ([viewController isKindOfClass:[FacebookFeedViewController class]]) {
        pageIndex = ((FacebookFeedViewController*) viewController).index;
    } else if ([viewController isKindOfClass:[TwitterFeedViewController class]]) {
        pageIndex = ((TwitterFeedViewController*) viewController).index;
    } else {
        pageIndex = ((InstagramFeedViewController*) viewController).index;
    }

    pageIndex++;
    if (pageIndex == 5) {
        return nil;
    }
    return [self viewControllerAtIndex:pageIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {

    return 4;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

@end
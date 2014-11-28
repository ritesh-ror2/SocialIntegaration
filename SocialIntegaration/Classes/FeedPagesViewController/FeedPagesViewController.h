//
//  FeedPagesViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookFeedViewController.h"
#import "TwitterFeedViewController.h"
#import "InstagramFeedViewController.h"
#import "ViewController.h"
#import "PageControllerCustomClass.h"

@interface FeedPagesViewController : PageControllerCustomClass <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@end

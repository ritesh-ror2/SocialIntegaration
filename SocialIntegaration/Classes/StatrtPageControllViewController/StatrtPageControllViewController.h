//
//  ViewController.h
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterProfileViewController.h"
#import "InstagramProfileViewController.h"
#import "PageControllerCustomClass.h"

@interface StatrtPageControllViewController: PageControllerCustomClass <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

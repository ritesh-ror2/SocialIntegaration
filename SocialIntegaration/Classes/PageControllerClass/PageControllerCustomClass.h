//
//  PageControllerCustomClass.h
//  SocialIntegaration
//
//  Created by GrepRuby on 27/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXPageControl.h"

@interface PageControllerCustomClass : UIViewController

@property (nonatomic, strong) FXPageControl *navigationPageControl;
@property (nonatomic, strong) FXPageControl *origanalPageControl;

- (void)configureNavigationPageControlWithPageControl:(FXPageControl*) pageControl;
- (void)autoConfigureNavigationPageControlWithPageViewController:(UIPageViewController*) pageViewController;
- (void)updateNavigationPageControl;
- (void)setupNavigationPageControl;
- (void)setupNavigationPageControlProfile;
- (void)setupNavigationPageControlFeeds;
- (void)setupNavigationPageControlFrame:(UIView *)vwPageController;
- (void)setPageNumber:(int)pageNumber;

@end

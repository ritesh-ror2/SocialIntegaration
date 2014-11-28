//
//  PageControllerCustomClass.h
//  SocialIntegaration
//
//  Created by GrepRuby on 27/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageControllerCustomClass : UIViewController

@property (nonatomic, strong) UIPageControl *navigationPageControl;
@property (nonatomic, strong) UIPageControl *origanalPageControl;

-(void)configureNavigationPageControlWithPageControl:(UIPageControl*) pageControl;
-(void)autoConfigureNavigationPageControlWithPageViewController:(UIPageViewController*) pageViewController;
-(void)updateNavigationPageControl;
-(void)setupNavigationPageControl;
- (void)setupNavigationPageControlFrame;


@end

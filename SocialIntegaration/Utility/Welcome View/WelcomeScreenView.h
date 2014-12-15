//
//  WelcomeScreenView.h
//  WelcomeScreenDemo
//
//  Created by GrepRuby on 04/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPageOfScrollView.h"

@protocol WelcomeScreenDelegate;

@interface WelcomeScreenView : UIView<UIScrollViewDelegate, UIGestureRecognizerDelegate> {

    UIScrollView *welcomeScreenScrollVw;
    UIPageControl *welcomeScreenPageControl;
    NSMutableArray *welcomeScreenPageList;
}

@property (nonatomic, readonly) UIScrollView *welcomeScreenScrollVw;
@property (unsafe_unretained) id <WelcomeScreenDelegate> delegate;

//Function
- (id)initWithFrame:(CGRect)frame withDelegate:(id<WelcomeScreenDelegate>)welcomeScreenDelegate;
- (void)reloadWelcomeScreenScrollView;
- (CustomPageOfScrollView *)getViewFromScrollViewatIndexPage:(NSInteger)indexPage;
- (void)hidePageController:(BOOL)isHidden;

@end

@protocol WelcomeScreenDelegate <NSObject>

@required

- (NSInteger)numberOfPagesInWelcomeScreen:(WelcomeScreenView*)welcomeScreen;
- (void)welcomeScreen:(WelcomeScreenView*)welcomeScreen setLayoutInScrollVw:(CustomPageOfScrollView *)viewOfLayout withPageIndex:(NSInteger)pageIndex;
- (BOOL)canMoveInCircleOfWelcomeScreen:(WelcomeScreenView *)welcomeScreen;

@optional

- (void)welcomeScreen:(WelcomeScreenView*)welcomeScreen didSelectPagewithIndexNumber:(NSInteger)pageIndex withSubviewComponent:(UIView *)subview;

@end

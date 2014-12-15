//
//  WelcomeScreenView.m
//  WelcomeScreenDemo
//
//  Created by GrepRuby on 04/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "WelcomeScreenView.h"

@implementation WelcomeScreenView

@synthesize welcomeScreenScrollVw;
@synthesize delegate;

#pragma mark - initialize method to set images of scroll view

- (id)initWithFrame:(CGRect)frame withDelegate:(id<WelcomeScreenDelegate>)welcomeScreenDelegate {

    self = [super initWithFrame:frame];

    if (self) {

        //init all component of scroll view
        self.delegate = welcomeScreenDelegate;
        [self initializedComponentOfWelcomeScreenScrollView];
  }
  return self;
}

#pragma mark - Initialized component in scroll view

/*********************************************************************************************
 Function is used to initialize all component of welcome view only at first time
 *********************************************************************************************/

- (void)initializedComponentOfWelcomeScreenScrollView {

    [welcomeScreenPageControl setHidden:YES];

        //CGRect * rect =
    //scroll view
    welcomeScreenScrollVw = [[UIScrollView alloc]initWithFrame:self.frame];
    welcomeScreenScrollVw.pagingEnabled = YES;
    welcomeScreenScrollVw.scrollEnabled = YES;
    welcomeScreenScrollVw.delegate = self;
    welcomeScreenScrollVw.showsHorizontalScrollIndicator = NO;
    welcomeScreenScrollVw.backgroundColor = [UIColor blackColor];
    [self addSubview:welcomeScreenScrollVw];

    //page controller
    welcomeScreenPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 170, welcomeScreenScrollVw.frame.size.width, 36)];
    welcomeScreenPageControl.currentPage = 0;
    welcomeScreenPageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    welcomeScreenPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self addSubview:welcomeScreenPageControl];
    [self bringSubviewToFront:welcomeScreenPageControl];

    //allocate arry to contain page list
    welcomeScreenPageList = [[NSMutableArray alloc]init];

    [self loadWelcomeView];//load pages in scroll view
}

- (void)hidePageController:(BOOL)isHidden {

    welcomeScreenPageControl.hidden = isHidden;
}

#pragma mark - Load scroll View 
/*********************************************************************************************
 Function to show number of page in welcome screen and call function to make layout of screen
 *********************************************************************************************/

- (void)loadWelcomeView {

    //delegete to set number of page
    if ([self.delegate respondsToSelector:@selector(numberOfPagesInWelcomeScreen:)]) { //delegate method to set page count
        [self.delegate numberOfPagesInWelcomeScreen:self];
    }

    //delegete to set circle view or not
    if ([self.delegate respondsToSelector:@selector(canMoveInCircleOfWelcomeScreen:)]) { //delegate method to set page count
        [self.delegate canMoveInCircleOfWelcomeScreen:self];
    }

    welcomeScreenPageControl.numberOfPages = [self.delegate numberOfPagesInWelcomeScreen:self];
    [self setContentsOfWelcomeScreensScrollVw];
}

#pragma mark - Set content size of scroll view
/*********************************************************************************************
 Function to set pages layout by delegate
 *********************************************************************************************/

- (void)setContentsOfWelcomeScreensScrollVw {

    int pageCount = [self.delegate numberOfPagesInWelcomeScreen:self];
    int xAxisOfPage;
    if ([self.delegate canMoveInCircleOfWelcomeScreen:self] == YES) {
        xAxisOfPage = 320;
    } else {
         xAxisOfPage = 0;
    }
    for (int loopPageCount=1; loopPageCount<=pageCount; loopPageCount++) {

        CustomPageOfScrollView *vwOfWelcomeScreenPage = [[CustomPageOfScrollView alloc]initWithFrame: CGRectMake(xAxisOfPage, 0, welcomeScreenScrollVw.frame.size.width, welcomeScreenScrollVw.frame.size.height)];
        vwOfWelcomeScreenPage.pageIndex = loopPageCount; //set property of view
        [welcomeScreenScrollVw addSubview:vwOfWelcomeScreenPage];

        if ([self.delegate respondsToSelector:@selector(welcomeScreen:setLayoutInScrollVw:withPageIndex:)]) {

            NSLog(@" *** Delegate to set content of scroll View ***");
            [self.delegate welcomeScreen:self setLayoutInScrollVw:vwOfWelcomeScreenPage withPageIndex:loopPageCount];

            //Add gesture recognizer to each subview
            // [self addGestureRecognizerInWelcomeScreenOfScrollVw:vwOfWelcomeScreenPage];
            [welcomeScreenPageList addObject:vwOfWelcomeScreenPage]; //add view in arry
        }
        xAxisOfPage = xAxisOfPage + welcomeScreenScrollVw.frame.size.width; //set frame of y axis after one image
    }

    if ([self.delegate canMoveInCircleOfWelcomeScreen:self] == YES) {

        welcomeScreenScrollVw.contentSize = CGSizeMake(welcomeScreenScrollVw.frame.size.width *(pageCount+2), welcomeScreenScrollVw.frame.size.height);
        [welcomeScreenScrollVw scrollRectToVisible:CGRectMake(320, 0, welcomeScreenScrollVw.frame.size.width, welcomeScreenScrollVw.frame.size.height) animated:YES];
    } else {

        welcomeScreenScrollVw.contentSize = CGSizeMake(welcomeScreenScrollVw.frame.size.width *pageCount, welcomeScreenScrollVw.frame.size.height);
        [welcomeScreenScrollVw scrollRectToVisible:CGRectMake(0, 0, welcomeScreenScrollVw.frame.size.width, welcomeScreenScrollVw.frame.size.height) animated:YES];
    }
}

#pragma mark - Add gesture to scroll view
/*********************************************************************************************
 Function to add gesture on subview of scroll view page
 *********************************************************************************************/

- (void)addGestureRecognizerInWelcomeScreenOfScrollVw:(UIView *)welcomeScreenPage {

    //add gesture to view
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getGestureRecognizer:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [welcomeScreenPage addGestureRecognizer:tapRecognizer];

    for (UIView *subviewOfWelcomeScreenPage in welcomeScreenPage.subviews) {

        if (subviewOfWelcomeScreenPage.userInteractionEnabled == YES) {

            //add gesture to sub view
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getGestureRecognizer:)];
            tapRecognizer.numberOfTapsRequired = 1;
            [subviewOfWelcomeScreenPage addGestureRecognizer:tapRecognizer];
        }
    }
}

#pragma mark -  Get gesture of view
/*********************************************************************************************
 Function to get view of gesture recognizer
 *********************************************************************************************/

- (void)getGestureRecognizer:(UITapGestureRecognizer*)sender {

    UIView *subview = sender.view;
    //  NSLog(@"%d", subview.tag);//By tag, you can find out where you had typed.

    if ([subview isKindOfClass:[CustomPageOfScrollView class]]) {

        CustomPageOfScrollView *parentVwOfSubVw = (CustomPageOfScrollView*)subview;

        if ([self.delegate respondsToSelector:@selector(welcomeScreen:didSelectPagewithIndexNumber:withSubviewComponent:)]) {
            [self.delegate welcomeScreen:self didSelectPagewithIndexNumber:parentVwOfSubVw.pageIndex withSubviewComponent:subview];
        }
    } else {
        UIView* topView = subview;

        while(topView.superview != nil) {

            topView = topView.superview;
            if ([topView isKindOfClass:[CustomPageOfScrollView class]]) {

                CustomPageOfScrollView *parentVwOfSubVw = (CustomPageOfScrollView*)topView;
                //NSLog(@"%i", parentVwOfSubVw.pageIndex);

                if ([self.delegate respondsToSelector:@selector(welcomeScreen:didSelectPagewithIndexNumber:withSubviewComponent:)]) {

                    [self.delegate welcomeScreen:self didSelectPagewithIndexNumber:parentVwOfSubVw.pageIndex withSubviewComponent:subview];
                    break;
                }
            }
        }
    }
}

#pragma mark - Get View of page
/*********************************************************************************************
 Function to get scroll view page by using index
 *********************************************************************************************/

- (CustomPageOfScrollView *)getViewFromScrollViewatIndexPage:(NSInteger)indexPage {

    CustomPageOfScrollView *customPageOfVw = [welcomeScreenPageList objectAtIndex:indexPage - 1];
    return customPageOfVw;
}

#pragma mark - Reload scroll View
/*********************************************************************************************
 Function to reload welcome scroll view
 *********************************************************************************************/

- (void)reloadWelcomeScreenScrollView {

    [self loadWelcomeView];
}

#pragma mark - UIScroll view delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    float fractionalPage;

    if (scrollView == welcomeScreenScrollVw) {

        CGFloat pageWidth = welcomeScreenScrollVw.frame.size.width;
        //NSLog(@"%f, %f", pageWidth, welcomeScreenScrollVw.contentOffset.x);
        fractionalPage = welcomeScreenScrollVw.contentOffset.x / pageWidth;
    }

    NSInteger page = lround(fractionalPage);

    if (page == 0) {
        [welcomeScreenPageControl setHidden:YES];
    } else {
        [welcomeScreenPageControl setHidden:NO];
    }

    if ([self.delegate canMoveInCircleOfWelcomeScreen:self] == YES) {

        if (page > 0) {
            page = page - 1;
        }
    }

    welcomeScreenPageControl.currentPage = page; //set current scroll page
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {

    if ([self.delegate canMoveInCircleOfWelcomeScreen:self] == YES) {

        int pageCount = [self.delegate numberOfPagesInWelcomeScreen:self];//page count
        int xAxis = (welcomeScreenScrollVw.frame.size.width*pageCount); //xaxis of screen
        //  int page2 = (welcomeScreenScrollVw.frame.size.width*pageCount);

        if (welcomeScreenScrollVw.contentOffset.x == 0) {
            // user is scrolling to the left from page 1 to last
            [welcomeScreenScrollVw scrollRectToVisible:CGRectMake(xAxis, 0, welcomeScreenScrollVw.frame.size.width, welcomeScreenScrollVw.frame.size.height) animated:NO];
        } else if (welcomeScreenScrollVw.contentOffset.x == welcomeScreenScrollVw.frame.size.width*(pageCount+1)) {
            // user is scrolling to the right from last page to first
            [welcomeScreenScrollVw scrollRectToVisible:CGRectMake(320, 0, welcomeScreenScrollVw.frame.size.width, welcomeScreenScrollVw.frame.size.height) animated:NO];
        }
    } else {

    }
}

@end

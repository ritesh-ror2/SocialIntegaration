//
//  ShowImageOrVideoViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShowImageOrVideoViewController.h"
#import "FXPageControl.h"

@interface ShowImageOrVideoViewController () <UIWebViewDelegate, NSURLConnectionDelegate> {

    NSMutableData *_responseData;
    NSURLConnection *conn;
}

@end

@implementation ShowImageOrVideoViewController

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

    NSArray *arryVws = self.navigationController.navigationBar.subviews;

    for (UIView *vw in arryVws) {
        if ([vw isKindOfClass:[FXPageControl class]]) {
            [vw setHidden:YES];
        }
    }

    self.navigationItem.title = @"ShowDetails";
    self.navigationController.navigationBarHidden = NO;
    [self.webViewVideo setHidden:YES];
    self.navigationController.navigationBar.translucent = YES;

    if ([self.userInfo.type isEqualToString:@"video"]) { // video on web view

        NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.userInfo.videoUrl]];
        [self.webViewVideo loadRequest:urlRequest];
        [self.webViewVideo setHidden:NO];
    } else {
        [self.imgVwLargeImg setHidden:NO];
        if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {
            self.imgVwLargeImg.Image = self.imgLarge;
        } else {
            [self.imgVwLargeImg sd_setImageWithURL:[NSURL URLWithString:self.userInfo.postImg] placeholderImage:nil];
        }
    }
    self.scrollVwImg.backgroundColor=[UIColor whiteColor];
    self.scrollVwImg.minimumZoomScale = 1.0;
    self.scrollVwImg.maximumZoomScale = 3.0;
    [self.scrollVwImg setZoomScale:1.0];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - ImageVwDelegates

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return self.imgVwLargeImg;
}

@end

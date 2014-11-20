//
//  ShowImageOrVideoViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShowImageOrVideoViewController.h"

@interface ShowImageOrVideoViewController () <UIWebViewDelegate>

@end

@implementation ShowImageOrVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"%@", self.userInfo);
    self.navigationItem.title = @"ShowDetails";
    self.navigationController.navigationBarHidden = NO;
    [self.webViewVideo setHidden:YES];
    [self.asyImgView setHidden:YES];
    self.navigationController.navigationBar.translucent = YES;

    if ([self.userInfo.type isEqualToString:@"video"]) {

        NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.userInfo.videoUrl]];
        [self.webViewVideo loadRequest:urlRequest];
        [self.webViewVideo setHidden:NO];
    } else {
        self.asyImgView.imageURL = [NSURL URLWithString:self.userInfo.strPostImg];
        [self.asyImgView setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

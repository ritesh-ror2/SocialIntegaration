//
//  ShowImageOrVideoViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShowImageOrVideoViewController.h"

@interface ShowImageOrVideoViewController () <UIWebViewDelegate, NSURLConnectionDelegate> {

    NSMutableData *_responseData;
    NSURLConnection *conn;
}

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

        if([self.userInfo.strUserSocialType isEqualToString:@"Facebook"]) {

            [Constant showNetworkIndicator];
            [self getLargeImageOfFacebook];
            return;
        }
        self.asyImgView.imageURL = [NSURL URLWithString:self.userInfo.strPostImg];
        [self.asyImgView setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLargeImageOfFacebook {

    NSString *strUrl =  [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", self.userInfo.objectIdFB];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
        // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    self.imgVwLagre.hidden = NO;
    [Constant hideNetworkIndicator];
    UIImage *image = [UIImage imageWithData:_responseData];
    self.imgVwLagre.image = image;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
        // The request has failed for some reason!

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

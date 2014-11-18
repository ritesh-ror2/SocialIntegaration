//
//  GiveCommentViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "GiveCommentViewController.h"
#import "Constant.h"
#import <Social/Social.h>

@interface GiveCommentViewController () <IGRequestDelegate, IGRequestDelegate>

@end

@implementation GiveCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.view];
    txtVwCommnet.inputAccessoryView = navBar;
    self.view.backgroundColor = [UIColor whiteColor];

    txtVwCommnet.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtVwCommnet.layer.borderWidth = 1.0;
    txtVwCommnet.layer.cornerRadius = 3.0;

    [self showNavigationBarColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNavigationBarColor {

    if ([self.userInfo.strUserSocialType isEqualToString:@"Facebook"]) {

        imgVwbackg.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
        [btnPost addTarget:self action:@selector(postOnFbBtnTapped:) forControlEvents:UIControlEventTouchUpInside];//
        lblNavHeading.text = @"Facebook";
    } else if ([self.userInfo.strUserSocialType isEqualToString:@"Twitter"]) {

        lblNavHeading.text = @"Twitter";
        imgVwbackg.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
        [btnPost addTarget:self action:@selector(postCommentOnInstagram) forControlEvents:UIControlEventTouchUpInside];//postCommentOnTwitter
    } else {

        lblNavHeading.text = @"Instagram";
         imgVwbackg.backgroundColor =  [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
        [btnPost addTarget:self action:@selector(postCommentOnInstagram) forControlEvents:UIControlEventTouchUpInside];
    }
    [self setProfileImage];
}

- (void)setProfileImage {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.userInfo.strUserImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwProfile.image = imgProfile;
        });
    });
}

- (IBAction)cancelBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {

    navBar.hidden = NO;
    lblHeading.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    navBar.hidden = YES;

    if (textView.text.length == 0) {
        lblHeading.hidden = NO;
    }
}

- (IBAction)postOnFbBtnTapped:(id)sender {

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            txtVwCommnet.text, @"message",
                            nil
                            ];
    NSString *strUrl = [NSString stringWithFormat:@"/%@",self.userInfo.objectIdFB];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:strUrl
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {

                              } else {
                                  NSDictionary *dict = (NSDictionary *)result;
                                  if ([[dict valueForKey:@"success"]isEqualToString:@"1"]){
                                      [Constant showAlert:@"Success" forMessage:@"Post Your comment"];
                                  }
                              }
                              /* handle the result */
                          }];
}


- (void)postCommentOnTwitter {

    NSString *strRetweet = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json",self.userInfo.statusId];

    NSURL *requestURL = [NSURL URLWithString:strRetweet];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:nil];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error)
     {
       NSLog(@"%@ !#" , [error description]);
       NSArray *arryTwitte = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:&error];

       if (arryTwitte.count != 0) {
           dispatch_async(dispatch_get_main_queue(), ^{

                   //[self convertDataOfTwitterIntoModel: arryTwitte];//convert into model class
           });
       } else {
           dispatch_async(dispatch_get_main_queue(), ^{

               [sharedAppDelegate.spinner hide:YES];
               [Constant showAlert:@"Message" forMessage:@"No Tweet in your account."];
           });
       }
     }];
}


- (void)postCommentOnInstagram {

        //api.instagram.com/v1/media/555/comments?access_token=ACCESS-TOKEN
    NSString *strMethodName = [NSString stringWithFormat:@"media/%@/comments",self.userInfo.statusId];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"comment from app", @"text", nil]; //fetch feed
    [sharedAppDelegate.instagram requestWithMethodName:strMethodName params:params httpMethod:@"POST" delegate:self];
}

#pragma mark - IGRequestDelegate

- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {

    NSLog(@"Instagram did fail: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
    [sharedAppDelegate.spinner hide:YES];
}

- (void)request:(IGRequest *)request didLoad:(id)result {

    NSLog(@"Instagram did load: %@", result);
    NSArray *arry = [result objectForKey:@"data"];
}


- (IBAction)doneBtnTapped:(id)sender {

    navBar.hidden = YES;
    [self.view endEditing:YES];
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

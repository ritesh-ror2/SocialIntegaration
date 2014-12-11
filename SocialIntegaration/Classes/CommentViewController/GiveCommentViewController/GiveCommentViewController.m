//
//  GiveCommentViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "GiveCommentViewController.h"
#import "Constant.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

@interface GiveCommentViewController () <IGRequestDelegate, IGRequestDelegate> {

    NSMutableDictionary *facebookUserInfo;
    UserProfile *userProfileFB;
}

@end

@implementation GiveCommentViewController

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
    [self.view bringSubviewToFront:self.view];
        //self.txtVwGiveComment.inputAccessoryView = navBar;
    self.view.backgroundColor = [UIColor whiteColor];

    self.txtVwGiveComment.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.txtVwGiveComment.layer.borderWidth = 1.0;
    self.txtVwGiveComment.layer.cornerRadius = 3.0;

     userProfileFB = [UserProfile getProfile:@"Facebook"];
    [self showNavigationBarColor];
    [self getFriendList];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.txtVwGiveComment.delegate  = self;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - KeyBoard Notification

- (void)keyboardWillShow:(NSNotification*)aNotification {

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    if (IS_IOS8) {
        navBar.frame = CGRectMake(0, self.view.frame.size.height - (kbSize.height+44), navBar.frame.size.width, navBar.frame.size.height);
    } else {
        navBar.frame = CGRectMake(0, self.view.frame.size.height - kbSize.height, navBar.frame.size.width, navBar.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification {

    navBar.frame = CGRectMake(0, self.view.frame.size.height ,navBar.frame.size.width, navBar.frame.size.height);
    navBar.hidden = YES;
}


#pragma mark - Show navbar color accordinf to facebook and twitter
/**************************************************************************************************
 Function to show navbar color accordinf to facebook and twitter
 **************************************************************************************************/

- (void)showNavigationBarColor {

    if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {

        imgVwbackg.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
        [btnPost addTarget:self action:@selector(postOnFbBtnTapped:) forControlEvents:UIControlEventTouchUpInside];//
        lblNavHeading.text = @"Facebook";
    } else if ([self.userInfo.userSocialType isEqualToString:@"Twitter"]) {

        lblNavHeading.text = @"Twitter";
        imgVwbackg.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
        [btnPost addTarget:self action:@selector(postCommentOnTwitter) forControlEvents:UIControlEventTouchUpInside];
    } else {

        lblNavHeading.text = @"Instagram";
         imgVwbackg.backgroundColor =  [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
        [btnPost addTarget:self action:@selector(postCommentOnInstagram) forControlEvents:UIControlEventTouchUpInside];
    }
    [self setProfileImage];
}

#pragma mark - Set profile image of login user
/**************************************************************************************************
 Function to set profile image of login user
 **************************************************************************************************/

- (void)setProfileImage {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfileFB.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwProfile.image = imgProfile;
        });
    });
}

#pragma mark - Cancel btn tapped
/**************************************************************************************************
 Function to cancel btn tapped
 **************************************************************************************************/

- (IBAction)cancelBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UItext field Delegates

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

#pragma mark - Post comment on fb
/**************************************************************************************************
 Function to post comment on fb
 **************************************************************************************************/

- (IBAction)postOnFbBtnTapped:(id)sender {

    [Constant showNetworkIndicator];

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"publish_stream", @"publish_actions"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.txtVwGiveComment.text, @"message",
                            nil
                            ];
    NSString *strUrl = [NSString stringWithFormat:@"/%@/comments",self.userInfo.objectIdFB];
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

                                  NSLog(@"ERROR %@" ,[error localizedDescription]);
                              } else {

                                  [Constant hideNetworkIndicator];
                                  [Constant showAlert:@"Success" forMessage:@"Post comment successfully."];
                                  [self.navigationController popViewControllerAnimated:YES];
                              }
                          }];
        }];

}

- (void)getFriendList {

    [FBRequestConnection startWithGraphPath:@"/me/friendlists"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {
                                  NSLog(@"%@", [error localizedDescription]);
                              } else {
                                  NSLog(@"@@@@");
                              }
                              /* handle the result */
                          }];
}

#pragma mark - Post comment on twitter
/**************************************************************************************************
 Function to post comment on twitter
 **************************************************************************************************/

- (void)postCommentOnTwitter {

    NSDictionary *param = @{@"status": self.txtVwGiveComment.text,
                            @"in_reply_to_status_id": self.userInfo.statusId};

    NSString *strFavourateUrl = [NSString stringWithFormat:TWITTER_POST_URL];
    NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
                                  URL:requestURL parameters:param];

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
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if (arryTwitte.count != 0) {
               dispatch_async(dispatch_get_main_queue(), ^{

                   [Constant hideNetworkIndicator];
                   [Constant showAlert:@"Success" forMessage:@"Reply sent successfully."];
                   [self.navigationController popViewControllerAnimated:YES];
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [Constant hideNetworkIndicator];
               });
           }
       }
     }];
}

#pragma mark - Post comment on Instagram
/**************************************************************************************************
 Function to post comment on instagram
 **************************************************************************************************/

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
    [Constant hideNetworkIndicator];
}

- (void)request:(IGRequest *)request didLoad:(id)result {

    NSLog(@"Instagram did load: %@", result);
}

#pragma mark - Done btn tapped on nav bar
/**************************************************************************************************
 Function to done btn tapped on nav bar
 **************************************************************************************************/

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

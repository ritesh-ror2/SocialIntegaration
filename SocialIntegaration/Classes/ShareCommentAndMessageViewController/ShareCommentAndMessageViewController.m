//
//  ShareCommentAndMessageViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 26/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShareCommentAndMessageViewController.h"
#import "UserProfile.h"

@interface ShareCommentAndMessageViewController () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate> {

    UIImage *imgSelected;
}

@property (nonatomic, strong) UserProfile *profileFB;
@property (nonatomic, strong) UserProfile *profileTwitter;
@property (nonatomic, strong) UserProfile *profileInstagram;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation ShareCommentAndMessageViewController

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

    self.navigationController.navigationBarHidden = YES;

    self.profileFB = [UserProfile getProfile:@"Facebook"];
    self.profileTwitter = [UserProfile getProfile:@"Twitter"];
    self.profileInstagram = [UserProfile getProfile:@"Instagram"];

    [self setProfileImageOfTwitter:self.profileTwitter.userImg];
    [self setProfileImageOfFB:self.profileFB.userImg];

    self.scrollVwComposre.pagingEnabled = YES;
    self.scrollVwComposre.contentSize = CGSizeMake(self.view.frame.size.width*2,self.vwFB.frame.size.height);

    self.txtVwFB.layer.borderWidth = 1.0;
    self.txtVwTwitter.layer.borderWidth = 1.0;

    pageControl.currentPage = 0;
    pageControl.numberOfPages = 2;

    [self setHeadingAndNavigationColor];
    [self getListOfFollowers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHeadingAndNavigationColor {

    lblFbHeading.text = @"Facebook";
    imgVwFB.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];

    lblTwitterHeading.text = @"Twittter";
    imgVwTwitter.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
}

#pragma mark - Set profile image of twitter and Instagram

- (void)setProfileImageOfTwitter:(NSString *)profileImg {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwTwitterUserProfile.image = imgProfile;
        });
    });
}

- (void)setProfileImageOfFB:(NSString *)profileImg {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwFBUserProfile.image = imgProfile;
        });
    });
}

- (IBAction)shareOnFacebook:(id)sender {

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];
    [self.view endEditing:YES];

    if (self.txtVwFB.text.length == 0) {
        [Constant showAlert:@"Message" forMessage:@"Please enter message"];
        [sharedAppDelegate.spinner hide:YES];
        return;
    }

    NSData *imgData = UIImageJPEGRepresentation(imgSelected, 1.0);

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"publish_actions"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;

        NSDictionary *params;

            if (imgData != nil) {

                if (self.txtVwFB.text.length != 0) {
                   params = @{@"source":imgData,
                            @"message":self.txtVwFB.text};
                } else {
                    params = @{@"source":imgData};
                }
            /* make the API call */
            [FBRequestConnection startWithGraphPath:@"/me/photos"
                                         parameters:params
                                         HTTPMethod:@"POST"
                                  completionHandler:^(
                                                      FBRequestConnection *connection,
                                                      id result,
                                                      NSError *error
                                                      ) {

                                      if (!error) {
                                          [Constant showAlert:@"Success" forMessage:@"Post your status successfully."];
                                          [sharedAppDelegate.spinner hide:YES];
                                      } else {
                                          NSLog(@"%@",error.description);
                                          [sharedAppDelegate.spinner hide:YES];
                                      }
                                  }];
            } else {

                // Make the request
                params = @{@"message":self.txtVwFB.text};

                [FBRequestConnection startWithGraphPath:@"/me/feed"
                parameters:params
                HTTPMethod:@"POST"
                completionHandler:^(
                FBRequestConnection *connection,
                id result,
                NSError *error
                ) {
                    if (!error) {

                        [Constant showAlert:@"Success" forMessage:@"Post your status successfully."];
                        [sharedAppDelegate.spinner hide:YES];

                    } else {
                            //NSLog(error.description);
                        [sharedAppDelegate.spinner hide:YES];

                    }
                }];
            }
    }];
}

- (IBAction)selectPhotoFromGallary:(id)sender {

    UIAlertView *alertVwPhoto = [[UIAlertView alloc]initWithTitle:@"Select Photo" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Library", @"Camera", nil];
    [alertVwPhoto show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        return;
    }

    UIImagePickerControllerSourceType sourceType = 0;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    [self.imagePickerController setAllowsEditing:YES];
    [self.imagePickerController setDelegate:self];

        // the user clicked one of the OK/Cancel buttons
    switch (buttonIndex) {

        // Library
        case 1:
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;

        // Camera
        case 2:
            sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
    }

    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"Selected photo source not available for this device.",@"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK",@"")
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    [self.imagePickerController setSourceType:sourceType];
    [self presentViewController:self.imagePickerController animated:YES completion:Nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    imgSelected = originalImage;

    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (void) openLibraryToSelectPhoto {


}

- (IBAction)shareOnTwitter:(id)sender {

    [self.view endEditing:YES];

    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];
    
    if (self.txtVwTwitter.text.length == 0) {
        [Constant showAlert:@"Message" forMessage:@"Please enter message"];
        return;
    }
    NSDictionary *param = @{@"status": self.txtVwTwitter.text};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/update.json"];
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
       id result = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableLeaves
                              error:&error];
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if ([result isKindOfClass:[NSDictionary class]]) {
               dispatch_async(dispatch_get_main_queue(), ^{

                   [sharedAppDelegate.spinner hide:YES];
                   [Constant showAlert:@"Success" forMessage:@"Tweet successfully."];
                   [self.navigationController popViewControllerAnimated:YES];
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedAppDelegate.spinner hide:YES];
               });
           }
       }
     }];
}

- (void)getListOfFollowers {

    NSDictionary *param = @{@"user_id":self.profileTwitter.userId};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/followers/list.json"];
    NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:param];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error)
     {
       NSLog(@"%@ !#" , [error description]);
       id result = [NSJSONSerialization
                    JSONObjectWithData:responseData
                    options:NSJSONReadingMutableLeaves
                    error:&error];
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if ([result isKindOfClass:[NSDictionary class]]) {
               dispatch_async(dispatch_get_main_queue(), ^{


                   
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
               });
           }
       }
     }];
}


- (void)getListOfFriend {

    if (self.txtVwTwitter.text.length == 0) {
        [Constant showAlert:@"Message" forMessage:@"Please enter message"];
        return;
    }
    NSDictionary *param = @{@"user_id":self.profileTwitter.userId};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/friends/list.json"];
    NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:param];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error)
     {
       NSLog(@"%@ !#" , [error description]);
       id result = [NSJSONSerialization
                    JSONObjectWithData:responseData
                    options:NSJSONReadingMutableLeaves
                    error:&error];
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if ([result isKindOfClass:[NSDictionary class]]) {
               dispatch_async(dispatch_get_main_queue(), ^{


               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
               });
           }
       }
     }];
}

- (IBAction)sendDirectMessageOnTwitter:(id)sender {

    if (self.txtVwTwitter.text.length == 0) {
        [Constant showAlert:@"Message" forMessage:@"Please enter message"];
        return;
    }
    NSDictionary *param = @{@"user_id": @"",
                            @"text":self.txtVwTwitter.text};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/direct_messages/new.json"];
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
       id result = [NSJSONSerialization
                    JSONObjectWithData:responseData
                    options:NSJSONReadingMutableLeaves
                    error:&error];
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if ([result isKindOfClass:[NSDictionary class]]) {
               dispatch_async(dispatch_get_main_queue(), ^{

                   [sharedAppDelegate.spinner hide:YES];
                   [Constant showAlert:@"Success" forMessage:@"Tweet successfully."];
                   [self.navigationController popViewControllerAnimated:YES];
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedAppDelegate.spinner hide:YES];
               });
           }
       }
     }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    lblComment.hidden = YES;
    lblCommentTwitter.hidden = YES;
    self.navBar.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    [self.view endEditing:YES];
    self.navBar.hidden = YES;

    if (self.txtVwTwitter.text.length == 0) {
        lblCommentTwitter.hidden = NO;
    }
    if (self.txtVwFB.text.length == 0) {
        lblComment.hidden = NO;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    int pageWidth = scrollView.frame.size.width;
    float lroundPage = scrollView.contentOffset.x/pageWidth;
    
    NSInteger page = lround(lroundPage);
    pageControl.currentPage = page;
}

- (IBAction)cancelBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtnTapped:(id)sender {

    [self.view endEditing:YES];
    self.navBar.hidden = YES;
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

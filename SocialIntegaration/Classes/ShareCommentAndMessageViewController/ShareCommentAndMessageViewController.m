//
//  ShareCommentAndMessageViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 26/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ShareCommentAndMessageViewController.h"
#import "UserProfile.h"
#import "UserInfo.h"

@interface ShareCommentAndMessageViewController () <UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate> {

    UIImage *imgSelected;
}

@property (nonatomic, strong) UserProfile *profileFB;
@property (nonatomic, strong) UserProfile *profileTwitter;
@property (nonatomic, strong) UserProfile *profileInstagram;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSMutableArray *arryUsers;

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
    self.scrollVwComposre.contentSize = CGSizeMake(self.view.frame.size.width*2,120);

    self.txtVwFB.layer.borderWidth = 1.0;
    self.txtVwTwitter.layer.borderWidth = 1.0;

    pageControl.currentPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];

    self.arryUsers = [[NSMutableArray alloc]init];

//    self.tbleVwUser.layer.borderColor = [[UIColor blackColor]CGColor];
//    self.tbleVwUser.layer.borderWidth = 1.0;
    [self setHeadingAndNavigationColor];
    [self getListOfFollowers];
    [self addPageControl];

    sharedAppDelegate.isFirstTimeLaunch = NO;
}

- (void) addPageControl {


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

    [Constant showNetworkIndicator];

    [self.view endEditing:YES];

    if (self.txtVwFB.text.length == 0) {

        [Constant showAlert:@"Message" forMessage:@"Please enter message."];
        [Constant hideNetworkIndicator];
        return;
    }

    BOOL isFBUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISFBLOGIN];
    if (isFBUserLogin == YES) {

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
                                              [Constant hideNetworkIndicator];

                                          } else {
                                              NSLog(@"%@",error.description);
                                              [Constant hideNetworkIndicator];
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
                            [Constant hideNetworkIndicator];
                        } else {
                                //NSLog(error.description);
                            [Constant hideNetworkIndicator];
                        }
                    }];
                }
        }];
    }
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

    /*[self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];*/

    [Constant showNetworkIndicator];
    
    if (self.txtVwTwitter.text.length == 0) {
        [Constant showAlert:@"Message" forMessage:@"Please enter message."];
        return;
    }

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == YES) {

        NSData *imgData = UIImageJPEGRepresentation(imgSelected, 1.0f);

        if (imgData != nil) {

            [self postImageOnTwitter:imgData];
        } else {

            NSDictionary *param = @{@"status": self.txtVwTwitter.text};

            NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/update.json"];
            NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
            SLRequest  *timelineRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:param];

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

                       if ([[result valueForKey:@"errors"] count] == 0) {
                           // [sharedAppDelegate.spinner hide:YES];
                           [Constant hideNetworkIndicator];
                           [Constant showAlert:@"Success" forMessage:@"Tweet successfully."];
                       }
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
    }
}

- (void)postImageOnTwitter:(NSData *)imgData {

    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];

    NSDictionary *paramater = @{@"status": self.txtVwTwitter.text};

    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:paramater];
    [postRequest addMultipartData:imgData withName:@"media[]" type:@"image/jpeg" filename:@"image.jpg"];
    [postRequest setAccount:sharedAppDelegate.twitterAccount]; // or  postRequest.account = twitterAccount;

    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                    
    NSLog(@"output = %@",output);

    [Constant showAlert:@"Message" forMessage:@"Tweet Successfully"];
                    
    dispatch_async(dispatch_get_main_queue(), ^{

        });

    }];
}

- (void)getListOfFollowers {

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == YES) {
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
               if (![result isKindOfClass:[NSDictionary class]]) {
                   dispatch_async(dispatch_get_main_queue(), ^{

                       NSArray *arryUser = [result valueForKey:@"users"];
                       [self convertDataOfFriend:arryUser];
                       [self getListOfFriend];
                   });
               } else {
                   dispatch_async(dispatch_get_main_queue(), ^{

                       NSArray *arryUser = [result valueForKey:@"users"];
                       [self convertDataOfFriend:arryUser];
                       [self getListOfFriend];
                   });
           }
         }];
    }
}

- (void)convertDataOfFriend:(NSArray*)arryResult {

    NSLog(@"%@", arryResult);

    for (NSDictionary *dictUser in arryResult) {

        UserInfo *info = [[UserInfo alloc]init];
        info.strUserName = [dictUser valueForKey:@"name"];
        info.fromId = [dictUser valueForKey:@"id"];
        [self.arryUsers addObject:info];
    }
}

- (void)getListOfFriends {

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
           if (![result isKindOfClass:[NSDictionary class]]) {
               dispatch_async(dispatch_get_main_queue(), ^{

                   NSArray *arryUser = [result valueForKey:@"users"];
                   [self convertDataOfFriend:arryUser];
                   [self getListOfFriend];

               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{

                   NSDictionary *dictUser = (NSDictionary *)result;

                   UserInfo *info = [[UserInfo alloc]init];
                   info.strUserName = [dictUser valueForKey:@"name"];
                   info.fromId = [dictUser valueForKey:@"id"];
                   [self.arryUsers addObject:info];
               });
           }
       }
     }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"%i", self.arryUsers.count);
    return [self.arryUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userlist"];
    if(cell == nil) {

        cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"userlist"];
    }

    cell.textLabel.text = [[self.arryUsers objectAtIndex:indexPath.row] strUserName];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    cell.textLabel.textColor = [UIColor colorWithRed:90/256.0f green:108/256.0f blue:168/256.0f alpha:1.0] ;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *userInfo = [self.arryUsers objectAtIndex:indexPath.row];
    NSString *strTaggedName = userInfo.strUserName;
    NSString *strTaggedUser = [self.txtVwTwitter.text stringByAppendingString:strTaggedName];

        //  NSMutableAttributedString *strTwitterTags = [[NSMutableAttributedString alloc]initWithString:strTaggedUser];

        // [strTwitterTags addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0] range:NSMakeRange(strTaggedUser.length - strTaggedName.length, strTaggedName.length)];
    self.txtVwTwitter.text = @"";
    self.txtVwTwitter.text = strTaggedUser;
}

- (void)openUsersListInTwitter {

    [self.view endEditing:YES];
    [self.toolBar setHidden:YES];

    [UIView animateWithDuration:0.5 animations:^{

        [self.tbleVwUser reloadData];
        [self.tbleVwUser setHidden:NO];
        self.tbleVwUser.frame = CGRectMake(0, self.view.frame.size.height - 260, 320, 210);
    }];
}


- (void)getListOfFriend {

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
           if (![result isKindOfClass:[NSDictionary class]]) {
               dispatch_async(dispatch_get_main_queue(), ^{

                   NSArray *arryUser = [result valueForKey:@"users"];
                   [self convertDataOfFriend:arryUser];
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{

                   NSArray *arryUser = [result valueForKey:@"users"];
                   [self convertDataOfFriend:arryUser];
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

                   [Constant hideNetworkIndicator];
                   [Constant showAlert:@"Success" forMessage:@"Tweet successfully."];
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

- (void)textViewDidBeginEditing:(UITextView *)textView {

    self.tbleVwUser.hidden = YES;
    self.tbleVwUser.frame = CGRectMake(0, self.view.frame.size.height, 320, 210);
    lblComment.hidden = YES;
    lblCommentTwitter.hidden = YES;
    self.toolBar.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {

    [self.view endEditing:YES];
    self.toolBar.hidden = YES;

    if (self.txtVwTwitter.text.length == 0) {
        lblCommentTwitter.hidden = NO;
    }
    if (self.txtVwFB.text.length == 0) {
        lblComment.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {

    if (![textView.text isEqualToString:@""]) {
    NSString *strLastText = [textView.text substringFromIndex: textView.text.length - 1];

    if (textView == self.txtVwTwitter) {

        if ([strLastText isEqualToString:@"@"]) {
            [self openUsersListInTwitter];
        } else {
                self.toolBar.hidden = NO;
        }
    }
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
    self.toolBar.hidden = YES;
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

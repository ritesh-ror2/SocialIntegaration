//
//  PostStatusViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 17/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "PostStatusViewController.h"
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"
#import "UserInfo.h"

@interface PostStatusViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

    UIImage *imgSelected;
}

@property (nonatomic, strong) UserProfile *userProfile;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSMutableArray *arryUsers;

@end

@implementation PostStatusViewController

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

    self.navigationController.navigationBarHidden = YES;

    self.txtVwPost.layer.borderWidth = 1.0;
    self.txtVwPost.layer.borderColor = [[UIColor blackColor]CGColor];
    self.arryUsers = [[NSMutableArray alloc]init];

    [self setHeadingAndNavigationColor];

    self.tbleVwUser.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    if ([self.strPOstSocialType isEqualToString:@"Facebook"]) {
        self.userProfile = [UserProfile getProfile:@"Facebook"];
    } else if ([self.strPOstSocialType isEqualToString:@"Twitter"]){
        self.userProfile = [UserProfile getProfile:@"Twitter"];
        [self getListOfFollowers];
    } else {
        self.userProfile = [UserProfile getProfile:@"Instagram"];
    }

    [self setProfileImage:self.userProfile.userImg];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Keyboard notification

- (void)keyboardWillShow:(NSNotification*)aNotification {

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    if (IS_IOS8) {
        self.toolBar.frame = CGRectMake(0, self.view.frame.size.height -(kbSize.height+44), self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    } else {
        self.toolBar.frame = CGRectMake(0, self.view.frame.size.height - (kbSize.height+44), self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification {

    self.toolBar.frame = CGRectMake(0, self.view.frame.size.height ,self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    self.toolBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

#pragma mark - Set navigation color
/**************************************************************************************************
 Function to set navigation color according to twitter and facebook
 **************************************************************************************************/

- (void)setHeadingAndNavigationColor {

    if ([self.strPOstSocialType isEqualToString:@"Facebook"]) {

        lblHeading.text = @"Facebook";
        imgVeNavbar.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    } else {
        lblHeading.text = @"Twitter";
        imgVeNavbar.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
    }

}

#pragma mark - Set profile image of twitter
/**************************************************************************************************
 Function to set Profile image of Twitter
 **************************************************************************************************/

- (void)setProfileImage:(NSString *)profileImg {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:profileImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwOfUserProfile.image = imgProfile;
        });
    });
}


- (IBAction)postBtnTapped:(id)sender {

    if ([self.strPOstSocialType isEqualToString:@"Facebook"]) {
        [self shareOnFacebook:nil];
    } else if ([self.strPOstSocialType isEqualToString:@"Twitter"]){
        [self shareOnTwitter:nil];
    } else {


    }
}
#pragma mark - Share post on Fb
/**************************************************************************************************
 Function to share post on fb
 **************************************************************************************************/

- (IBAction)shareOnFacebook:(id)sender {

    [Constant showNetworkIndicator];

    [self.view endEditing:YES];

    if (self.txtVwPost.text.length == 0) {

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

                if (self.txtVwPost.text.length != 0) {
                    params = @{@"source":imgData,
                               @"message":self.txtVwPost.text};
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
                params = @{@"message":self.txtVwPost.text};

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

#pragma mark - Select photo from galary or camera
/**************************************************************************************************
 Function to select photo from galary and camera
 **************************************************************************************************/

- (IBAction)selectPhotoFromGallary:(id)sender {

    UIAlertView *alertVwPhoto = [[UIAlertView alloc]initWithTitle:@"Select Photo" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Library", @"Camera", nil];
    [alertVwPhoto show];
}

#pragma mark- UIAlert view Delegates

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

#pragma mark - Share on twitter
/**************************************************************************************************
 Function to share post on  twitter
 **************************************************************************************************/

- (IBAction)shareOnTwitter:(id)sender {

    [self.view endEditing:YES];
    [Constant showNetworkIndicator];

    if (self.txtVwPost.text.length == 0) {
        [Constant showAlert:@"Message" forMessage:@"Please enter message."];
        return;
    }

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == YES) {

        NSData *imgData = UIImageJPEGRepresentation(imgSelected, 1.0f);

        if (imgData != nil) {

            [self postImageOnTwitter:imgData];//post with image
            return;
        } else {

            NSDictionary *param = @{@"status": self.txtVwPost.text};

            NSString *strFavourateUrl = [NSString stringWithFormat:TWITTER_POST_URL];// @"https://api.twitter.com/1.1/statuses/update.json"];
            NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
            SLRequest  *timelineRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:param];

            timelineRequest.account = sharedAppDelegate.twitterAccount;

            [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error) {

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

#pragma mark - Share status with image on twitter
/**************************************************************************************************
 Function to share status with image on twitter
 **************************************************************************************************/

- (void)postImageOnTwitter:(NSData *)imgData {

    NSURL *urlPostImage = [NSURL URLWithString:TWITTER_POST_IMAGE];

    NSDictionary *paramater = @{@"status": self.txtVwPost.text};

    NSData *data = UIImagePNGRepresentation(imgSelected);
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:urlPostImage parameters:paramater];
    [postRequest addMultipartData:data withName:@"media[]" type:@"image/png" filename:nil];
    [postRequest setAccount:sharedAppDelegate.twitterAccount]; // or  postRequest.account = twitterAccount;

    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

        NSString *output = [NSString stringWithFormat:@"HTTP response status: %li", (long)[urlResponse statusCode]];

        NSLog(@"output = %@",output);

            //[Constant showAlert:@"Message" forMessage:@"Tweet Successfully"];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });

    }];
}

#pragma mark - Get list of followers in twitter
/**************************************************************************************************
 Function to get list of followers in twitter
 **************************************************************************************************/

- (void)getListOfFollowers {

    BOOL isTwitterUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:ISTWITTERLOGIN];
    if (isTwitterUserLogin == YES) {
        NSDictionary *param = @{@"user_id":self.userProfile.userId};

        NSString *strFavourateUrl = [NSString stringWithFormat:TWITTER_FOLLOWERS];
        NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
        SLRequest *timelineRequest = [SLRequest
                                      requestForServiceType:SLServiceTypeTwitter
                                      requestMethod:SLRequestMethodGET
                                      URL:requestURL parameters:param];

        timelineRequest.account = sharedAppDelegate.twitterAccount;

        [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error) {

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

#pragma mark - Convert data into model class in twitter
/**************************************************************************************************
 Function to convert data into model class in twitter
 **************************************************************************************************/

- (void)convertDataOfFriend:(NSArray*)arryResult {

    for (NSDictionary *dictUser in arryResult) {

        UserInfo *info = [[UserInfo alloc]init];
        info.userName = [dictUser valueForKey:@"name"];
        info.fromId = [dictUser valueForKey:@"id"];
        [self.arryUsers addObject:info];
    }
}

#pragma mark - UITableview Datadource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.arryUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userlist"];
    if(cell == nil) {

        cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"userlist"];
    }

    cell.textLabel.text = [[self.arryUsers objectAtIndex:indexPath.row] userName];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    cell.textLabel.textColor = [UIColor colorWithRed:90/256.0f green:108/256.0f blue:168/256.0f alpha:1.0] ;
    return cell;
}

#pragma mark - UITable view Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UserInfo *userInfo = [self.arryUsers objectAtIndex:indexPath.row];
    NSString *strTaggedName = userInfo.userName;
    NSString *strTaggedUser = [self.txtVwPost.text stringByAppendingString:strTaggedName];
    self.txtVwPost.text = @"";
    self.txtVwPost.text = strTaggedUser;
}

#pragma mark - Show user list in twitter
/**************************************************************************************************
 Function to open user list
 **************************************************************************************************/

- (void)openUsersListInTwitter {

    [self.view endEditing:YES];
    [self.toolBar setHidden:YES];

    [UIView animateWithDuration:0.5 animations:^{

        [self.tbleVwUser reloadData];
        [self.tbleVwUser setHidden:NO];
        self.tbleVwUser.frame = CGRectMake(0, self.view.frame.size.height - 260, self.view.frame.size.width, 210);
    }];
}

#pragma mark - Get list of friend in twitter
/**************************************************************************************************
 Function to get list of friend in twitter
 **************************************************************************************************/

- (void)getListOfFriend {

    NSDictionary *param = @{@"user_id":self.userProfile.userId};

    NSString *strFavourateUrl = [NSString stringWithFormat:TWITTER_FRIEND];
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

#pragma mark - UITextview Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView {

    self.tbleVwUser.hidden = YES;
    self.tbleVwUser.frame = CGRectMake(0, self.view.frame.size.height, 320, 210);
    lblComment.hidden = YES;
    self.toolBar.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self.view endEditing:YES];
    self.toolBar.hidden = YES;
    
    if (self.txtVwPost.text.length == 0) {
        lblComment.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (![textView.text isEqualToString:@""]) {
        
        NSString *strLastText = [textView.text substringFromIndex: textView.text.length - 1];
        if ([self.strPOstSocialType isEqualToString:@"Twitter"]) {
            
            if ([strLastText isEqualToString:@"@"]) {
                [self openUsersListInTwitter];
            } else {
                self.toolBar.hidden = NO;
            }
        }
    }
}

#pragma mark - Cancel btn tapped

- (IBAction)cancelBtnTapped:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Done btn tapped

- (IBAction)doneBtnTapped:(id)sender {
    
    [self.view endEditing:YES];
    self.toolBar.hidden = YES;
}

@end

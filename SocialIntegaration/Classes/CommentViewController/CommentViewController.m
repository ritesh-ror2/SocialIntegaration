//
//  CommentViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "CommentViewController.h"
#import "Constant.h"
#import "CustomTableCell.h"
#import "Constant.h"
#import "UserComment.h"
#import "CommentCustomCell.h"
#import "UserProfile+DatabaseHelper.h"
#import "GiveCommentViewController.h"
#import "ShowImageOrVideoViewController.h"
#import "ShowOtherUserProfileViewController.h"
#import <Social/Social.h>

@interface CommentViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, IGRequestDelegate, IGRequestDelegate, UIAlertViewDelegate, NSURLConnectionDelegate> {

    NSString *strBtnTitle;
    UserProfile *userProfile;
    NSMutableData *fbData;

    NSMutableData *_responseData;
    NSURLConnection *connFBLagreImage;

    CGPoint touchBegin;
    CGPoint touchMove;
}

@property (nonatomic, strong) NSArray *arrayFriend;
@property (nonatomic, strong) NSMutableArray *arryComment;
@property (nonatomic, strong) NSMutableArray *arryTaggedUser;


@end

@implementation CommentViewController

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

    self.navigationController.navigationBarHidden = YES;
        // imgVwBackground.backgroundColor =  [UIColor whiteColor]; //
        //imgVwBackground.userInteractionEnabled = YES;
        //  imgVwBackground.multipleTouchEnabled = YES;

    vwOfComment.backgroundColor = [UIColor colorWithRed:240/256.0f green:240/256.0f blue:240/256.0f alpha:1.0];
    tbleVwComment.backgroundColor = [UIColor clearColor];

        //[btnMoreTweet setBackgroundColor:[UIColor redColor]];
    [self.view bringSubviewToFront:imgVwNavigation];
    [self.view bringSubviewToFront:lblHeading];
    [self.view bringSubviewToFront:btnRight];
    [self.view bringSubviewToFront:btnLeft];

        // scrollVw.contentSize = CGSizeMake(scrollVw.frame.size.width, 420);
        // scrollVw.pagingEnabled = YES;

    self.arrayFriend = @[@"@qwe123", @"qwe123", @"qwe123"];

    self.arryComment = [[NSMutableArray alloc]init];
    [tbleVwComment setBackgroundColor: [UIColor clearColor]];
    
    [self.view addSubview:sharedAppDelegate.spinner];
    [self.view bringSubviewToFront:sharedAppDelegate.spinner];
    [sharedAppDelegate.spinner show:YES];
    [btnLike addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];

    lblFavourite.text = self.userInfo.favourateCount;
    lblRetweet.text = self.userInfo.retweetCount;

    if ([self.userInfo.retweeted isEqualToString:@"1"]) {
        [btnRetweet setImage:[UIImage imageNamed:@"Retweet_active.png"] forState:UIControlStateNormal];//selected
    } else {
         [btnRetweet setImage:[UIImage imageNamed:@"Retweet1.png"]forState:UIControlStateNormal];///deselected
    }

    if ([self.userInfo.favourated isEqualToString:@"1"]) {
        [btnFavourite setImage:[UIImage imageNamed:@"favourite_active.png"]forState:UIControlStateNormal];//selected
    } else {
        [btnFavourite setImage:[UIImage imageNamed:@"favourite1.png"] forState:UIControlStateNormal];//deselected
    }

    self.arryTaggedUser = [[NSMutableArray alloc]init];

    [self getLargeImageOfFacebook];
    [self getLikeCountOfFb];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
    [self setHeadingAndRightBtn];
        //[self giveCommentToInstagram];
    [self showUserTagged:nil];
    [self setProfilePic:self.userInfo];
    [self setProfilePicOfPostUser:self.userInfo];

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}
- (void)setHeadingAndRightBtn {

    if ([self.userInfo.strUserSocialType isEqualToString:@"Facebook"]) {

        [btnRight setTitle:@"Post" forState:UIControlStateNormal];
        lblHeading.text = @"Facebook";
        strBtnTitle = @"Post";
        [self facebookConfiguration];
        [self fectchAllComment];
        imgVwNavigation.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];

    } else if ([self.userInfo.strUserSocialType isEqualToString:@"Instagram"]) {
        [btnRight setTitle:@"Post" forState:UIControlStateNormal];
        lblHeading.text = @"Instagram";
        strBtnTitle = @"Post";
        [self fetchInstagrameComment];
        [self instagramConfiguration];
        imgVwNavigation.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];

    } else {
        [btnRight setTitle:@"Tweet" forState:UIControlStateNormal];
        lblHeading.text = @"Twitter";
        strBtnTitle = @"Tweet";
        [self setCommentOfUser:self.userInfo];
        [self fetchRetewwtOfTwitter];
        [self twitterConfiguration];
        imgVwNavigation.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
    }
}

- (void)fetchRetewwtOfTwitter {

    NSString *strUrl1 = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweets/%@.json",self.userInfo.statusId];
    NSURL *requestURL = [NSURL URLWithString:strUrl1];
    NSLog(@"%@", requestURL);
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:nil];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error) {

         if (error) {

             [Constant showAlert:ERROR_CONNECTING forMessage:ERROR_AUTHEN];
             [sharedAppDelegate.spinner hide:YES];
             return ;
         } else {

             NSArray *arryTwitte = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:NSJSONReadingMutableLeaves
                                    error:&error];

             NSLog(@"%@", [error debugDescription]);
             if (arryTwitte.count != 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{

                 [[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISTWITTERLOGIN];
                 [[NSUserDefaults standardUserDefaults]synchronize];

                [self convertDataOfTwitterIntoModel:arryTwitte];
             });
             } else {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [sharedAppDelegate.spinner hide:YES];
                      [Constant showAlert:@"Message" forMessage:@"No Comment is there."];
                  });
             }
     }
 }];
}

#pragma mark - Convert data of twitter in to model class

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    [self.arryComment removeAllObjects];
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            NSLog(@"**%@", dictData);

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];
            UserComment *usercomment =[[UserComment alloc]init];
            usercomment.userName = [postUserDetailDict valueForKey:@"name"];
            usercomment.userImg = [postUserDetailDict valueForKey:@"profile_image_url"];

//            NSArray *arryMedia = [[dictData objectForKey:@"extended_entities"] objectForKey:@"media"];
//
//            if (arryMedia.count>0) {
//                userInfo.strPostImg = [[arryMedia objectAtIndex:0] valueForKey:@"media_url"];
//            }
            usercomment.userComment = [dictData valueForKey:@"text"];
            usercomment.socialType = @"Twitter";
            NSString *strDate = [self dateOfTwitter:[dictData objectForKey:@"created_at"]];
            usercomment.time = [Constant convertDateOFTweeter:strDate];
            [self.arryComment addObject:usercomment];
        }
    }

    if(self.arryComment.count == 0) {
        [Constant showAlert:@"Messgae" forMessage:@"No comment found"];
        [sharedAppDelegate.spinner setHidden:YES];
        return;
    }
    [sharedAppDelegate.spinner hide:YES];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    [tbleVwComment reloadData];
}

#pragma mark - Convert date into "YYYY-dd-mm" formate

- (NSString *)dateOfTwitter:(NSString *)createdDate {

    NSString *strDateInDatabaseFormate;

    NSString *strYear = [createdDate substringWithRange:NSMakeRange(createdDate.length-4, 4)];
    NSString *strMonth = [createdDate substringWithRange:NSMakeRange(4, 3)];
    NSString *strDate = [createdDate substringWithRange:NSMakeRange(8, 2)];

    NSString *strTime = [createdDate substringWithRange:NSMakeRange(11, 8)];//14

    NSString *finalDate = [NSString stringWithFormat:@"%@ %@ %@", strDate, strMonth, strYear];

    strDateInDatabaseFormate = [NSString stringWithFormat:@"%@ %@", finalDate, strTime];

    return strDateInDatabaseFormate;
}


- (void)fetchInstagrameComment {

    //api.instagram.com/v1/media/555/comments?access_token=ACCESS-TOKEN
    NSString *strUrl = [NSString stringWithFormat:@"media/%@/comments",self.userInfo.statusId];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:strUrl, @"method", nil]; //fetch feed
    [sharedAppDelegate.instagram requestWithParams:params
                                          delegate:self];
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
    [self convertDataOfInstagramIntoModelClass:arry];
}

- (void)convertDataOfInstagramIntoModelClass:(NSArray *)arryOfInstagrame {

    if (arryOfInstagrame.count != 0) {
        [self.arryComment removeAllObjects];
    }

    @autoreleasepool {

        for (NSDictionary *dictData in arryOfInstagrame) {

            UserComment *userComment =[[UserComment alloc]init];

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"caption"];

            NSDictionary *dictUserInfo = [postUserDetailDict objectForKey:@"from"];
            userComment.userName = [dictUserInfo valueForKey:@"username"];
            userComment.userId = [dictUserInfo valueForKey:@"id"];
            userComment.userImg = [dictUserInfo valueForKey:@"profile_picture"];

            userComment.userComment = [postUserDetailDict valueForKey:@"text"];
            NSString *strDate = [postUserDetailDict objectForKey:@"created_time"];

            NSTimeInterval interval = strDate.doubleValue;
            NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970: interval];
            NSLog(@"Date = %@", convertedDate);
            userComment.time = [Constant convertDateOFInstagram:convertedDate];

//            NSDictionary *dictImage = [dictData objectForKey:@"images"];
//            userInfo.strPostImg = [[dictImage valueForKey:@"low_resolution"]objectForKey:@"url"];
//
//            userInfo.type = [dictData objectForKey:@"type"];
//            userInfo.strUserSocialType = @"Instagram";
//            userInfo.statusId = [dictData objectForKey:@"id"];

            [self.arryComment addObject:userComment];
        }
    }

    if(self.arryComment.count == 0) {
        [Constant showAlert:@"Messgae" forMessage:@"No comment found"];
        [sharedAppDelegate.spinner setHidden:YES];
        return;
    }
    [sharedAppDelegate.spinner hide:YES];
    [tbleVwComment reloadData];
}

- (void)fectchAllComment {
    
    NSString *strComment = [NSString stringWithFormat:@"/%@/comments", self.userInfo.objectIdFB];
    [FBRequestConnection startWithGraphPath:strComment
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
                                  NSArray *arryComment = [result objectForKey:@"data"];
                                  [self convertDataOfComment: arryComment];
                              }
                          }];
}

- (void)convertDataOfComment:(NSArray *)arryPost {

    [self.arryComment removeAllObjects];
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            UserComment *userComment = [[UserComment alloc]init];
            userComment.userComment = [dictData objectForKey:@"message"];
            userComment.time = [Constant convertDateOFFB:[dictData objectForKey:@"created_time"]];

                //userComment.userImg = [dictData objectForKey:@""];
            NSDictionary *fromDict = [dictData objectForKey:@"from"];
            userComment.userName = [fromDict objectForKey:@"name"];
            userComment.userId = [fromDict objectForKey:@"id"];
            userComment.commentId = [dictData objectForKey:@"id"];
            userComment.socialType = @"Facebook";
            [self.arryComment addObject:userComment];
        }
    }
    if (self.arryComment.count == 0) {
        [Constant showAlert:@"Message" forMessage:@"No Comment is there."];
        [sharedAppDelegate.spinner setHidden:YES];
        return;
    }

    [sharedAppDelegate.spinner hide:YES];

    [tbleVwComment reloadData];

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

- (void)setCommentOfUser:(UserInfo *)objUserInfo {

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                       context:nil];

    lblComment.frame = CGRectMake(70, 21, 245, rect.size.height+10);
    lblComment.text = objUserInfo.strUserPost;
    lblName.text = objUserInfo.strUserName;
    
    asyVwOfPost.hidden = YES;
    btnShowImageOrVideo.hidden = YES;

    if (objUserInfo.strPostImg.length != 0) {

        asyVwOfPost.hidden = NO;
        asyVwOfPost.frame = CGRectMake(70, lblComment.frame.size.height + lblComment.frame.origin.y + 3, 245, 100);
        asyVwOfPost.imageURL = [NSURL URLWithString:objUserInfo.strPostImg];
        asyVwOfPost.backgroundColor = [UIColor clearColor];

        btnShowImageOrVideo.hidden = NO;
        btnShowImageOrVideo.frame = asyVwOfPost.frame;
        [self setFrameOfActivityView:asyVwOfPost.frame.size.height + asyVwOfPost.frame.origin.y + 10];
        int taggedUser =  [self setFramesOfTaggedUsers:asyVwOfPost.frame.size.height + asyVwOfPost.frame.origin.y + 95];
        imgVwBackground.frame = CGRectMake(0, 0, imgVwBackground.frame.size.width, lblComment.frame.size.height + lblComment.frame.origin.y + 140 + taggedUser);
    } else {

        [self setFrameOfActivityView:lblComment.frame.size.height + lblComment.frame.origin.y + 10];
        int taggedUser =  [self setFramesOfTaggedUsers:lblComment.frame.size.height + lblComment.frame.origin.y + 40];
        imgVwBackground.frame = CGRectMake(0, 0, imgVwBackground.frame.size.width, lblComment.frame.size.height + (lblComment.frame.origin.y + 40) + taggedUser);
    }

    tbleVwComment.frame = CGRectMake(0, imgVwBackground.frame.size.height+5, 320, (self.view.frame.size.height - (imgVwBackground.frame.size.height+ 115)));

    imgVwUser.frame = CGRectMake(10, imgVwBackground.frame.size.height+5 , 45, 45);

    if ([objUserInfo.type isEqualToString:@"video"]) {
        [btnShowImageOrVideo setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (int)setFramesOfTaggedUsers:(int)yAxis {

    if (self.arryTaggedUser.count == 0 ) {
        return 0;
    }
    NSMutableString *strUserNameList = [[NSMutableString alloc]init];

    UILabel *lblWith = [[UILabel alloc]initWithFrame:CGRectMake(2, yAxis, 40, 21)];
    lblWith.text = @"with";
    lblWith.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lblWith];

    int xAxis = 40;
    for (UserInfo *userInfo  in self.arryTaggedUser) {

        NSString *strName = userInfo.strUserName;
        [strUserNameList appendString:strName];

        CGRect rect = [strName boundingRectWithSize:CGSizeMake(250, 30)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                            context:nil];

        UIButton *btnTaggedUser = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTaggedUser setTitle:strName forState:UIControlStateNormal];
        btnTaggedUser.titleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:13.0];
        btnTaggedUser.frame = CGRectMake(xAxis, yAxis, rect.size.width, 30);
        btnTaggedUser.tag = [userInfo.fromId integerValue];
        [btnTaggedUser setTitleColor:[UIColor colorWithRed:90/256.0f green:108/256.0f blue:168/256.0f alpha:1.0] forState:UIControlStateNormal];
        [btnTaggedUser addTarget:self action:@selector(userProfileBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnTaggedUser];
        [self.view bringSubviewToFront:btnTaggedUser];

        if (xAxis < 320) {
            xAxis = xAxis + rect.size.width;
        } else {
            xAxis = 30;
            yAxis = yAxis + 33;
        }
    }
    if (strUserNameList.length != 0) {

        CGRect rect = [strUserNameList boundingRectWithSize:CGSizeMake(250, 30)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                            context:nil];
        return rect.size.height;
    } else {
        return 0;
    }

}

- (IBAction)moreBtnTapped:(id)sender {

    if([self.userInfo.strUserSocialType isEqualToString:@"Twitter"]) {

        [self.view bringSubviewToFront:btnBlock];
        [btnBlock setHidden:NO];
        btnBlock.frame = CGRectMake(btnMoreTweet.frame.origin.x - 30, btnMoreTweet.frame.origin.y+30, 60, 30);
    } else {
        [self.view bringSubviewToFront:btnDelete];

            // [btnDelete setHidden:NO];
            // btnDelete.frame = CGRectMake(btnMoreTweet.frame.origin.x - 30, btnMoreTweet.frame.origin.y+30, 60, 30);
    }
}

- (IBAction)blockTweetPost:(id)sender {

    NSString *strUser = [NSString stringWithFormat:@"Are you sure to block @%@ ?", self.userInfo.strUserName];
    UIAlertView *alertVw = [[UIAlertView alloc]initWithTitle:@"Block" message:strUser delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil];
    [alertVw show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {

        btnBlock.hidden = YES;
        return;
    }

    NSDictionary *param = @{@"screen_name":self.userInfo.screenName,
                            @"skip_status":@"1"};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/blocks/create.json"];
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
       NSLog(@"***%@***", result);

       if ([result isKindOfClass:[NSDictionary class]]) {
           if (![result valueForKey:@"error"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
               [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
     }];
}

- (IBAction)muteTwitterUser:(id)sender {

    NSNumber * myNumber =[NSNumber numberWithLongLong:[self.userInfo.fromId longLongValue]];

    NSDictionary *param = @{@"user_id": myNumber};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/mutes/users/create.json"];
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

       if (![result isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{

                       //https://api.twitter.com/1.1/mutes/users/destroy.json
               });
           } else {
               NSLog(@"%@", result);
           }
     }];
}

- (IBAction)deleteFBComment:(id)sender {

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"publish_actions"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;

            // NSLog(error.description);

        if (!error) {
        NSString *strUrl = [NSString stringWithFormat:@"/%@",self.userInfo.objectIdFB];
        [FBRequestConnection startWithGraphPath:strUrl
                                     parameters:nil
                                     HTTPMethod:@"DELETE"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                      // NSLog(error.description);
                                  if (!error) {
                                      NSLog(@"%@", result);
                                  }
                              }];
        }
    }];
}



- (IBAction)sharePost:(id)sender {

    NSMutableDictionary *params;
    if (self.userInfo.strPostImg.length != 0 && self.userInfo.strUserPost.length != 0) {
        NSString *strUrl =  [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", self.userInfo.objectIdFB];

        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Build great social apps and get more installs.", @"caption",
                 self.userInfo.strUserPost , @"description", // @"https://developers.facebook.com/ios", @"link",
                 strUrl, @"picture",
                 nil];

    } else if (self.userInfo.strUserPost.length != 0) {

        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Build great social apps and get more installs.", @"caption",
                  self.userInfo.strUserPost , @"description", nil];

    } else if (self.userInfo.strPostImg.length != 0) {

        NSString *strUrl =  [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", self.userInfo.objectIdFB];

        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Build great social apps and get more installs.", @"caption",
                    strUrl, @"picture", nil];
    }
        // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
                 // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             } else {
                     // Handle the publish feed callback
                 NSLog(@"completed");
             }
         }
     }];
}

- (void)userProfileBtnTapped:(id)sender{

        UIButton *btn = (UIButton *)sender;

      UserInfo *otherUserInfo = [[UserInfo alloc]init];
      otherUserInfo.strUserName = btn.titleLabel.text;
    otherUserInfo.fromId  = [NSString stringWithFormat:@"%i", btn.tag];
      otherUserInfo.strUserSocialType = @"Facebook";
      UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
      ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
      vwController.userInfo = otherUserInfo;
      [self.navigationController pushViewController:vwController animated:YES];

//    } if ([userInfo.strUserSocialType isEqualToString:@"Twitter"])  {
//
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
//        vwController.userInfo = userInfo;
//        [self.navigationController pushViewController:vwController animated:YES];
//    }
}


- (void)setFrameOfActivityView:(NSInteger)yAxis {

    if(yAxis < 50) {
        yAxis = 53;
    }
    [imgVwOfComentFb setFrame:CGRectMake(imgVwOfComentFb.frame.origin.x, yAxis, 20, 21)];
    [imgVwOfLikeFb setFrame:CGRectMake(imgVwOfLikeFb.frame.origin.x, yAxis, 20, 21)];
    [btnCommentFb setFrame:CGRectMake(btnCommentFb.frame.origin.x, yAxis+2,  btnCommentFb.frame.size.width,  btnCommentFb.frame.size.height)];
    [btnLike setFrame:CGRectMake(btnLike.frame.origin.x, yAxis+2, btnLike.frame.size.width, btnLike.frame.size.height)];
    [lblLikeCount setFrame:CGRectMake(lblLikeCount.frame.origin.x, yAxis+2, lblLikeCount.frame.size.width, lblLikeCount.frame.size.height)];
    [btnShare setFrame:CGRectMake(btnShare.frame.origin.x, yAxis+2, btnShare.frame.size.width, btnShare.frame.size.height)];


    [lblRetweet setFrame:CGRectMake(lblRetweet.frame.origin.x, yAxis+2, lblRetweet.frame.size.width, lblRetweet.frame.size.height)];
    [lblFavourite setFrame:CGRectMake(lblFavourite.frame.origin.x, yAxis+3, lblFavourite.frame.size.width, lblFavourite.frame.size.height)];

    [btnFavourite setFrame:CGRectMake(btnFavourite.frame.origin.x, yAxis, btnFavourite.frame.size.width, btnFavourite.frame.size.height)];
    [btnReply setFrame:CGRectMake(btnReply.frame.origin.x, yAxis, btnReply.frame.size.width, btnReply.frame.size.height)];
    [btnRetweet setFrame:CGRectMake(btnRetweet.frame.origin.x, yAxis,  btnRetweet.frame.size.width,  btnRetweet.frame.size.height)];
    [btnMoreTweet setFrame:CGRectMake(btnMoreTweet.frame.origin.x, yAxis,  btnMoreTweet.frame.size.width,  btnMoreTweet.frame.size.height)];

    [imgVwOfLikeInstagram setFrame:CGRectMake(imgVwOfLikeInstagram.frame.origin.x, yAxis, 20, 21)];
}


- (IBAction)cancelBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setProfilePicOfPostUser:(UserInfo *)userInfo  {

    if ([userInfo.strUserSocialType isEqualToString:@"Facebook"]) {

        dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(postImageQueue, ^{
            NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.postUserImg]];

            dispatch_async(dispatch_get_main_queue(), ^{

                UIImage *img = [UIImage imageWithData:image];
                UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
                imgVwPostUser.image = imgProfile;
            });
        });
    }

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userInfo.strUserImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwPostUser.image = imgProfile;
        });
    });
}

- (void)setProfilePic:(UserInfo *)userInfo  {

    userProfile = [UserProfile getProfile:userInfo.strUserSocialType];

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwUser.image = imgProfile;
        });
    });
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView == tbleVwComment) {
        return [self.arryComment count];
    }
    return [self.arrayFriend count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == tbleVwComment)  {

        NSString *cellIdentifier = @"cellComment";
        CommentCustomCell*cell;

        cell = (CommentCustomCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        UserComment *userComment = [self.arryComment objectAtIndex:indexPath.row];
        [cell setCommentInTableView:userComment];
        return cell;
        
    }
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell;

    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.arrayFriend objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == tbleVwComment) {

        UserComment *userComment = [self.arryComment objectAtIndex:indexPath.row];

        NSString *string = userComment.userComment;
        CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                           context:nil];

        return (rect.size.height + 35);//183 is height of other fixed content
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)facebookConfiguration {

    [imgVwOfComentFb setHidden:NO];
    [imgVwOfLikeFb setHidden:NO];
    [btnCommentFb setHidden:NO];
    [btnLike setHidden:NO];
    [lblLikeCount setHidden:NO];
    [btnShare setHidden:NO];
    [btnMoreTweet setHidden:YES];
}

- (void)twitterConfiguration  {

    [lblFavourite setHidden:NO];
    [lblRetweet setHidden:NO];
    [btnRetweet setHidden:NO];
    [btnFavourite setHidden:NO];
    [btnReply setHidden:NO];
    [btnMoreTweet setHidden:NO];
}

- (void)instagramConfiguration  {

    [imgVwOfComentFb setHidden:NO];
    [imgVwOfLikeInstagram setHidden:NO];
    [btnCommentFb setHidden:NO];
    [btnLike setHidden:NO];
    [lblLikeCount setHidden:NO];
}

- (void)showUserTagged:(id)sender {

    NSString *strUrl = [NSString stringWithFormat:@"/%@/tags",self.userInfo.objectIdFB];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:strUrl
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error) {
                                  NSLog(@"%2@", [error debugDescription]);
                              } else  {
                                  NSLog(@"%@", result);
                                  NSArray *arry = [result objectForKey:@"data"];
                                  [self taggedUser:arry];
                                  [self setCommentOfUser:self.userInfo];

                              }
                          }];
}

- (void)taggedUser:(NSArray *)arryUser {

    [self.arryTaggedUser removeAllObjects];
    for (NSDictionary *dictUser in arryUser) {

        UserInfo *userInfo = [[UserInfo alloc]init];
        userInfo.fromId = [dictUser valueForKey:@"id"];
        userInfo.strUserName = [dictUser valueForKey:@"name"];

        [self.arryTaggedUser addObject:userInfo];
    }
}

- (IBAction)likePost:(id)sender {

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"publish_stream", @"publish_actions"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;

        NSString *strUrl = [NSString stringWithFormat:@"/%@/likes",self.userInfo.objectIdFB];

        [FBRequestConnection startWithGraphPath:strUrl
                                     parameters:nil
                                     HTTPMethod:@"POST"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {

                                  if (error) {
                                      NSLog(@"%@", [error localizedDescription]);
                                  } else {

                                    imgVwOfLikeFb.image = [UIImage imageNamed:@"Liked-active.png"];
                                    [btnLike setTitle:@"Liked" forState:UIControlStateNormal];
                                    [btnLike setTitleColor:[UIColor colorWithRed:90/256.0f green:108/256.0f blue:168/256.0f alpha:1.0] forState:UIControlStateNormal];
                                    [btnLike removeTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
                                    [btnLike addTarget:self action:@selector(unlikedPost) forControlEvents:UIControlEventTouchUpInside];
                                    lblLikeCount.text = [NSString stringWithFormat:@"%i",lblLikeCount.text.integerValue +1];
                                  }
                              }];
    }];
}

- (void)getLikeCountOfFb {

    NSDictionary *dictMessage = @{@"summary": @"true"};

    NSString *strUrl = [NSString stringWithFormat:@"/%@/likes",self.userInfo.objectIdFB];
    [FBRequestConnection startWithGraphPath:strUrl
                                 parameters:dictMessage
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error){

                              } else {
                                 [self likeUserList:[[result objectForKey:@"summary"] valueForKey:@"total_count"]];

//                                  if ([[result valueForKey:@"paging"] count] >= 1) {
//                                      NSString *strNextPage = [[result valueForKey:@"paging"] valueForKey:@"next"];
//
//                                      [FBRequestConnection startWithGraphPath:strNextPage
//                                                                   parameters:nil
//                                                                   HTTPMethod:@"GET"
//                                                            completionHandler:^(
//                                                                                FBRequestConnection *connection,
//                                                                                id result1,
//                                                                                NSError *error
//                                                                                ) {
//                                                                if (error) {
//
//                                                                    NSLog(@"error");
//                                                                } else {
//
//                                                                    NSLog(@"sucess");
//                                                                }
//
//                                       }];
//                                       }
                              }
                          }];
        //   }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    NSLog(@"touch ** ");
    UITouch *touch = [[event allTouches]anyObject];
    touchBegin = [touch locationInView:self.view];

    for (UIView *view in self.view.subviews) {

        if ([view isKindOfClass:[btnBlock class]] &&
            CGRectContainsPoint(view.frame, touchBegin)) {

        } else {
            [btnBlock setHidden:YES];
        }
    }
}


- (void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *) event {

    NSLog(@"touch move ** ");

    UITouch *touch = [[event allTouches]anyObject];
    touchMove = [touch locationInView:self.view];

    if (touchMove.y > touchBegin.y) {

        NSLog(@"image show");

        [UIView animateWithDuration:0.4 animations:^{

            [imgVwPostImage setHidden:NO];
            [imgVwPostImage setFrame:CGRectMake(imgVwBackground.frame.origin.x, imgVwBackground.frame.origin.y, imgVwBackground.frame.size.width, imgVwBackground.frame.size.height)];        }];

    } else {
        NSLog(@"not show");
        [UIView animateWithDuration:0.4 animations:^{

            [imgVwPostImage setHidden:YES];
            [imgVwPostImage setFrame:CGRectMake(50, 0, 226,128)];
        }];

    }
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *) event {

    [UIView animateWithDuration:0.4 animations:^{

        [imgVwPostImage setHidden:YES];
        [imgVwPostImage setFrame:CGRectMake(50, 0, 226,128)];
    }];

}

- (void)likeUserList:(NSString*)strCount {

    lblLikeCount.text = [NSString stringWithFormat:@"%lld", strCount.longLongValue];

//    for (NSDictionary *dictResult in arryLikeUserList) {
//
//        if ([[dictResult objectForKey:@"id"]isEqualToString: userProfile.userId]) {
//
//            imgVwOfLikeFb.image = [UIImage imageNamed:@"Liked-active.png"];
//            [btnLike setTitle:@"Liked" forState:UIControlStateNormal];
//            btnLike.titleLabel.textColor = [UIColor blueColor];
//            [btnLike removeTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
//            [btnLike addTarget:self action:@selector(unlikedPost) forControlEvents:UIControlEventTouchUpInside];
//
//            break;
//        }
//    }

}

- (IBAction)playBtnTapped:(id)sender {

    UIStoryboard *storyBoard = [UIStoryboard  storyboardWithName:@"Main" bundle:nil];
    ShowImageOrVideoViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"ShowImageOrVideo"];
    viewController.userInfo = self.userInfo;
        // [self.navigationController pushViewController:viewController animated:YES];
}


- (IBAction)retweetBtnPressOrNot:(id)sender {

    NSData *data1 = UIImagePNGRepresentation(btnRetweet.imageView.image);
    NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"Retweet1.png"]);

    if ([data1 isEqual:data2]) { //retweet
        [self retweetOnTwitter:nil];
    } else { //delete retweet
        [self deleteRetweet:nil];
    }
}

- (IBAction)favouriteBtnPressOrNot:(id)sender {

    NSData *data1 = UIImagePNGRepresentation(btnFavourite.imageView.image);
    NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"Favourite1.png"]);

    if ([data1 isEqual:data2]) { //favoutrite
        [self favouriteOnTwitterPost:nil];
    } else { //delete retweet
        [self deleteFavouriteOnTwitterPost:nil];
    }
}

- (void)retweetOnTwitter:(id)sender {

    btnRetweet.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            // animate it to the identity transform (100% scale)
        btnRetweet.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
            [btnRetweet setImage:[UIImage imageNamed:@"Retweet_active.png"]forState:UIControlStateNormal];//selected
    }];

    return;
    NSString *strRetweet = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", self.userInfo.statusId];
        //api.twitter.com/1.1/statuses/update.json"];

    NSURL *requestURL = [NSURL URLWithString:strRetweet];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
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
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if (arryTwitte.count != 0) {
               dispatch_async(dispatch_get_main_queue(), ^{

                   btnRetweet.transform = CGAffineTransformMakeScale(0.01, 0.01);
                   [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                           // animate it to the identity transform (100% scale)
                    btnRetweet.transform = CGAffineTransformIdentity;
                   } completion:^(BOOL finished){
                           // if you want to do something once the animation finishes, put it here
                   }];
                   [btnRetweet setImage:[UIImage imageNamed:@"Retweet_active.png"]forState:UIControlStateNormal];//selected
                       //[Constant showAlert:@"Success" forMessage:@"Retweet has done successfully."];
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{

                   [Constant showAlert:@"Message" forMessage:@"No Tweet in your account."];
                   [sharedAppDelegate.spinner hide:YES];

               });
           }
       }
     }];
}

- (void)deleteRetweet:(id)sende {

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/destroy/%@.json",self.userInfo.statusId];

    NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
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
       NSLog(@"***%@***", [error localizedDescription]);

       if (!error) {
           if (arryTwitte.count != 0) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedAppDelegate.spinner hide:YES];
                   [btnRetweet setImage:[UIImage imageNamed:@"Retweet1.png"] forState:UIControlStateNormal];//deselected
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedAppDelegate.spinner hide:YES];
               });
           }
       }
     }];
}

- (void)favouriteOnTwitterPost:(id)sender {

    NSNumber * myNumber =[NSNumber numberWithLongLong:[self.userInfo.statusId longLongValue]];

    NSDictionary *param = @{@"id": myNumber};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/create.json"];
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
                   [sharedAppDelegate.spinner hide:YES];
                   btnFavourite.transform = CGAffineTransformMakeScale(0.01, 0.01);
                   [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                           // animate it to the identity transform (100% scale)
                       btnFavourite.transform = CGAffineTransformIdentity;
                   } completion:^(BOOL finished){
                        [btnFavourite setImage:[UIImage imageNamed:@"favourite_active.png"] forState:UIControlStateNormal];//selected
                   }];

               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedAppDelegate.spinner hide:YES];
               });
           }
       }
     }];
}

- (void)deleteFavouriteOnTwitterPost:(id)sender {

    NSDictionary *param = @{@"id": self.userInfo.statusId};

    NSString *strFavourateUrl = [NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/destroy.json"];
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
                   [sharedAppDelegate.spinner hide:YES];
                   [btnFavourite setImage:[UIImage imageNamed:@"Favourite1.png"] forState:UIControlStateNormal];//deselected
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [sharedAppDelegate.spinner hide:YES];
               });
           }
       }
     }];
}

- (void)unlikedPost {

    NSLog(@"%@", sharedAppDelegate.fbSession.accessTokenData);
    NSArray *writePermissions = @[@"publish_stream", @"publish_actions"];
    [sharedAppDelegate.fbSession requestNewPublishPermissions:writePermissions defaultAudience:FBSessionDefaultAudienceEveryone  completionHandler:^(FBSession *session, NSError *error) {
        sharedAppDelegate.fbSession = session;

        NSString *strUrl = [NSString stringWithFormat:@"/%@/likes",self.userInfo.objectIdFB];

    [FBRequestConnection startWithGraphPath:strUrl
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error){

                              } else {
                                  NSLog(@"**unliked**");
                                  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                          // animate it to the identity transform (100% scale)
                                      imgVwOfLikeFb.transform = CGAffineTransformIdentity;
                                  } completion:^(BOOL finished){
                                      imgVwOfLikeFb.image = [UIImage imageNamed:@"Likedd.png"];
                                  }];

                                  [btnLike setTitle:@"Like" forState:UIControlStateNormal];
                                  btnLike.titleLabel.textColor = [UIColor lightGrayColor];
                                  [btnLike removeTarget:self action:@selector(unlikedPost) forControlEvents:UIControlEventTouchUpInside];
                                  [btnLike addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
                              }
                          }];
    }];
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

- (IBAction)giveCommentByUser:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GiveCommentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"givecomment"];
    viewController.userInfo = self.userInfo;
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)getLargeImageOfFacebook {

    NSString *strUrl =  [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", self.userInfo.objectIdFB];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    connFBLagreImage = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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

    [sharedAppDelegate.spinner hide:YES];
    UIImage *image = [UIImage imageWithData:_responseData];
    imgVwPostImage.image = image;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
        // The request has failed for some reason!
    
}

@end

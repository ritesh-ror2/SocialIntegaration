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
#import "PostStatusViewController.h"
#import <Social/Social.h>

@interface CommentViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, IGRequestDelegate, IGRequestDelegate, UIAlertViewDelegate, NSURLConnectionDelegate> {

    NSString *strBtnTitle;
    NSString *nextTagedUrl;

    UserProfile *userProfile;
    NSMutableData *fbData;

    UILabel *lblTaggesName;
    UILabel *lblWith;

    NSMutableData *_responseData;
    NSURLConnection *connFBLagreImage;

    CGPoint touchBegin;
    CGPoint touchMove;

    NSMutableURLRequest *fbTaggedUserRequest;
    NSURLConnection *connetionTaggedUser;
    UITableView *tbleVwTaggedUser;

    UIActivityIndicatorView *activityIndicator;
    UIView *vwTaggedUser;
    int commentCount;
    PostStatusViewController *vwController;
}

@property (nonatomic, strong) NSMutableArray *arryComment;
@property (nonatomic, strong) NSMutableArray *arryTaggedUser;


@end

@implementation CommentViewController

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

    sharedAppDelegate.isFirstTimeLaunch = NO;

        // self.view.backgroundColor = [UIColor redColor];
    NSLog(@"%f",self.view.frame.size.height);
    vwOfComment.backgroundColor = [UIColor colorWithRed:240/256.0f green:240/256.0f blue:240/256.0f alpha:1.0];
    [self.view sendSubviewToBack:vwOfComment];
        // self.tabBarController.tabBar.hidden = NO;
        //[self.view bringSubviewToFront:self.tabBarController.tabBar];
    tbleVwComment.backgroundColor = [UIColor clearColor];

    [self.view bringSubviewToFront:imgVwNavigation];
    [self.view bringSubviewToFront:lblHeading];
    [self.view bringSubviewToFront:btnRight];
    [self.view bringSubviewToFront:btnLeft];

    self.arryComment = [[NSMutableArray alloc]init];
    [tbleVwComment setBackgroundColor: [UIColor clearColor]];

    [Constant showNetworkIndicator];

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

    activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 35)/2, (self.view.frame.size.height - 35)/2, 35, 35)];
    activityIndicator.center = self.view.center;

    vwTaggedUser = [[UIView alloc]initWithFrame:self.view.frame];
    vwTaggedUser.hidden = YES;
    vwTaggedUser.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:vwTaggedUser];

    tbleVwTaggedUser = [[UITableView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 200)/2, (self.view.frame.size.height - 250)/2, 200, 250)];
    tbleVwTaggedUser.dataSource = self;
    tbleVwTaggedUser.delegate = self;
    tbleVwTaggedUser.tableFooterView =  [[UIView alloc] initWithFrame:CGRectZero];
    [tbleVwTaggedUser setBackgroundColor:[UIColor whiteColor]];
    [vwTaggedUser addSubview:tbleVwTaggedUser];

    self.arryTaggedUser = [[NSMutableArray alloc]init];

    tbleVwComment.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

        // [self addUserImgAtLeftSide];

    if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {
        [self getLikeCountOfFb];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)addUserImgAtLeftSide {

    UserProfile *userProfile1 = [UserProfile getProfile:@"Facebook"];

    if (userProfile1 != nil) {

        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userProfile1.userImg]];
        UIImage *img = [UIImage imageWithData:image];
        UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
        UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
        imgVwProile.frame = CGRectMake(8, 22, 35, 35);
        [imgVwNavigation addSubview:imgVwProile];
        [imgVwNavigation bringSubviewToFront:imgVwProile];
        return;
    }
    UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed: @"user-selected.png"] withMask:[UIImage imageNamed:@"list-mask.png"]];
    UIImageView *imgVwProile = [[UIImageView alloc]initWithImage:imgProfile];
    imgVwProile.frame = CGRectMake(8, 25, 35, 35);

    [imgVwNavigation addSubview:imgVwProile];
    [imgVwNavigation bringSubviewToFront:imgVwProile];
}*/

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBarHidden = YES;
    [self setHeadingAndRightBtn];
    if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {
        [self showUserTagged:nil];
    }
    [self setProfilePic:self.userInfo];
    [self setProfilePicOfPostUser:self.userInfo];

    [Constant showNetworkIndicator];
}

- (IBAction)backBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Set heading anr right button title
/**************************************************************************************************
 Function to set heading anr right button title
 **************************************************************************************************/

- (void)setHeadingAndRightBtn {

    if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {

        if (self.userInfo.postImg.length != 0) {
            [self getLargeImageOfFacebook];
        }

        [btnRight setTitle:@"Post" forState:UIControlStateNormal];
        lblHeading.text = @"Facebook";
        strBtnTitle = @"Post";

        [self fectchFBComment];
        imgVwNavigation.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
    } else if ([self.userInfo.userSocialType isEqualToString:@"Instagram"]) {

//        [btnRight setImage:[UIImage imageNamed:@"inst_Camera.png"] forState:UIControlStateNormal];
//        [btnRight setImage:[UIImage imageNamed:@"inst_Camera.png"] forState:UIControlStateSelected];
//        [btnRight setImage:[UIImage imageNamed:@"inst_Camera.png"] forState:UIControlStateHighlighted];

        lblHeading.text = @"Instagram";
        [btnRight setTitle:@"Post" forState:UIControlStateNormal];

        [self setCommentOfpostDetail:self.userInfo];
        [self fetchInstagrameComment];
        imgVwNavigation.backgroundColor = [UIColor colorWithRed:36/256.0f green:84/256.0f blue:130/256.0f alpha:1.0];
    } else {

        [btnRight setTitle:@"Tweet" forState:UIControlStateNormal];
        lblHeading.text = @"Twitter";
        strBtnTitle = @"Tweet";

        [self setCommentOfpostDetail:self.userInfo];
        [self fetchRetewwtOfTwitter];
        imgVwNavigation.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];
    }
}

#pragma mark - Set heading anr right button title
/**************************************************************************************************
 Function to set heading anr right button title
 **************************************************************************************************/

- (void)showActivityVw {

    if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {
        [self facebookConfiguration];
    } else if ([self.userInfo.userSocialType isEqualToString:@"Instagram"]) {
        [self instagramConfiguration];
    } else {
        [self twitterConfiguration];
    }
}

#pragma mark - Set tweets of post
/**************************************************************************************************
 Function tweets of post
 **************************************************************************************************/

- (void)fetchRetewwtOfTwitter {

    NSString *strUrl = [NSString stringWithFormat:TWITTER_RETWEET,self.userInfo.statusId];
    NSURL *requestURL = [NSURL URLWithString:strUrl];
    NSLog(@"%@", requestURL);
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodGET
                                  URL:requestURL parameters:nil];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error) {

         if (error) {
            //[Constant showAlert:ERROR_CONNECTING forMessage:ERROR_AUTHEN];
             [Constant hideNetworkIndicator];
             return;
         } else {

             NSArray *arryTwitte = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:NSJSONReadingMutableLeaves
                                    error:&error];

             if (arryTwitte.count != 0) {
                 dispatch_async(dispatch_get_main_queue(), ^{

                //[[NSUserDefaults standardUserDefaults]setBool:YES forKey:ISTWITTERLOGIN];
                //[[NSUserDefaults standardUserDefaults]synchronize];
                [self convertDataOfTwitterIntoModel:arryTwitte];
             });
             } else {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [Constant hideNetworkIndicator];

                          // [Constant showAlert:@"Message" forMessage:@"No Comment is there."];
                       scrollVwShowComment.contentSize = CGSizeMake(320, imgVwBackground.frame.size.height);
                  });
             }
     }
 }];
}
- (void)noCommentInArray {

    dispatch_async(dispatch_get_main_queue(), ^{

        if(self.arryComment.count == 0) {

            [Constant hideNetworkIndicator];
            scrollVwShowComment.contentSize = CGSizeMake(320, imgVwBackground.frame.size.height+50);
            return;
        } else {
                //scrollVwShowComment.contentSize = CGSizeMake(320, imgVwBackground.frame.size.height+235);
            [Constant hideNetworkIndicator];
            [tbleVwComment reloadData];
        }
    });
}


#pragma mark - Convert data of twitter in to model class
/**************************************************************************************************
 Function to convert data of twitter in to model class
 **************************************************************************************************/

- (void)convertDataOfTwitterIntoModel:(NSArray *)arryPost {

    [self.arryComment removeAllObjects];
    @autoreleasepool {

        for (NSDictionary *dictData in arryPost) {

            NSLog(@"**%@", dictData);

            NSDictionary *postUserDetailDict = [dictData objectForKey:@"user"];
            UserComment *usercomment =[[UserComment alloc]init];
            usercomment.userName = [postUserDetailDict valueForKey:@"name"];
            usercomment.userImg = [postUserDetailDict valueForKey:@"profile_image_url"];
            usercomment.userComment = [dictData valueForKey:@"text"];
            usercomment.socialType = @"Twitter";
            NSString *strDate = [Constant convertDateOfTwitterInDatabaseFormate:[dictData objectForKey:@"created_at"]];
            usercomment.time = [Constant convertDateOFTwitter:strDate];
            [self.arryComment addObject:usercomment];
        }
    }
    [self performSelector:@selector(noCommentInArray) withObject:nil afterDelay:0.1];
}

#pragma mark - Fetch comment of instagram post
/**************************************************************************************************
 Function to fetch comment of instagram post
 **************************************************************************************************/

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
    [Constant hideNetworkIndicator];
}

- (void)request:(IGRequest *)request didLoad:(id)result {

    NSLog(@"Instagram did load: %@", result);
    NSArray *arry = [result objectForKey:@"data"];
    [self convertDataOfInstagramIntoModelClass:arry];
}

#pragma mark - Convert data of instagram in to model class
/**************************************************************************************************
 Function to convert data of instagram in to model class
 **************************************************************************************************/

- (void)convertDataOfInstagramIntoModelClass:(NSArray *)arryOfInstagrame {

    if (arryOfInstagrame.count != 0) {
        [self.arryComment removeAllObjects];
    }

    @autoreleasepool {

        for (NSDictionary *dictData in arryOfInstagrame) {

            UserComment *userComment =[[UserComment alloc]init];

            NSDictionary *dictUserInfo = [dictData objectForKey:@"from"];
            userComment.userName = [dictUserInfo valueForKey:@"username"];
            userComment.userId = [dictUserInfo valueForKey:@"id"];
            userComment.userImg = [dictUserInfo valueForKey:@"profile_picture"];

            userComment.userComment = [dictData valueForKey:@"text"];
             NSString *strDate = [dictData objectForKey:@"created_time"];

            NSTimeInterval interval = strDate.doubleValue;
            NSDate *convertedDate = [NSDate dateWithTimeIntervalSince1970: interval];
            NSLog(@"Date = %@", convertedDate);
            userComment.time = [Constant convertDateOFInstagram:convertedDate];
            [self.arryComment addObject:userComment];

//           NSDictionary *dictImage = [dictData objectForKey:@"images"];
//           userInfo.strPostImg = [[dictImage valueForKey:@"low_resolution"]objectForKey:@"url"];
//           userInfo.type = [dictData objectForKey:@"type"];
        }
    }
    [self performSelector:@selector(noCommentInArray) withObject:nil afterDelay:0.1];
}

#pragma mark - Fetch comment of fb post
/**************************************************************************************************
 Function to fetch comment of fb post
 **************************************************************************************************/

- (void)fectchFBComment {

    NSDictionary *param = @{@"summary":@"true"};
    
    NSString *strComment = [NSString stringWithFormat:@"/%@/comments", self.userInfo.objectIdFB];
    [FBRequestConnection startWithGraphPath:strComment
                                 parameters:param
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
                                  commentCount = [[[result objectForKey:@"summary"]valueForKey:@"total_count"]intValue];
                                  lblFBOrInstCommentCount.text = [NSString stringWithFormat:@"%i", commentCount];
                                  [self convertDataOfFBComment: arryComment];
                              }
                          }];
}

#pragma mark - Convert data of fb in to model class
/**************************************************************************************************
 Function to convert data of fb in to model class
 **************************************************************************************************/

- (void)convertDataOfFBComment:(NSArray *)arryPost {

    [self.arryComment removeAllObjects];

 /*   dispatch_async(dispatch_get_main_queue(), ^{

        if(arryPost.count == 0) {

            [Constant hideNetworkIndicator];
            scrollVwShowComment.contentSize = CGSizeMake(320, imgVwBackground.frame.size.height);
            return;
        } else {
            [Constant hideNetworkIndicator];
            [tbleVwComment reloadData];
        }
    });*/

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

    [self performSelector:@selector(noCommentInArray) withObject:nil afterDelay:0.1];
}

#pragma mark - set comment of post detail
/**************************************************************************************************
 Function to set comment of post detail
 **************************************************************************************************/

- (void)setCommentOfpostDetail:(UserInfo *)objUserInfo {

    NSString *string = objUserInfo.strUserPost;

    int widthOfComment;
    if (IS_IPHONE_6_IOS8) {
        widthOfComment = [Constant widthOfCommentLblOfTimelineAndProfile] + 50;
    } else if (IS_IPHONE_6P_IOS8) {
        widthOfComment = iPhone6_Plus_lbl_width + 80;
    } else {
        widthOfComment = iPhone5_lbl_width - 10;
    }

    CGRect rect = [string boundingRectWithSize:CGSizeMake(widthOfComment, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    lblComment.frame = CGRectMake(70, 25, widthOfComment, rect.size.height+10);
    lblComment.text = objUserInfo.strUserPost;
    lblName.text = objUserInfo.userName;
    
    asyVwOfPost.hidden = YES;
    btnShowImageOrVideo.hidden = YES;

    int heightPostImg;
    if (rect.size.height < 30){
       heightPostImg = 30;
    } else {
        heightPostImg = rect.size.height+10;
    }

    asyVwOfPost.layer.cornerRadius = 5.0;
    asyVwOfPost.layer.masksToBounds = YES;

    imgVwLagrePostImage.layer.cornerRadius = 5.0;
    imgVwLagrePostImage.layer.masksToBounds = YES;

    if (objUserInfo.postImg.length != 0) {

        asyVwOfPost.hidden = NO;
        btnShowImageOrVideo.hidden = NO;

        asyVwOfPost.frame = CGRectMake(64, heightPostImg + lblComment.frame.origin.y + 3, [Constant withOfImageInDescriptionView],  [Constant heightOfCellInTableVw]);
        imgVwLagrePostImage.frame = CGRectMake(64, heightPostImg + lblComment.frame.origin.y + 3,  [Constant withOfImageInDescriptionView],  [Constant heightOfCellInTableVw]);
            // asyVwOfPost.imageURL = [NSURL URLWithString:objUserInfo.postImg];
        [asyVwOfPost sd_setImageWithURL:[NSURL URLWithString:objUserInfo.postImg] placeholderImage:nil];
        asyVwOfPost.backgroundColor = [UIColor clearColor];

        btnShowImageOrVideo.frame = asyVwOfPost.frame;
        [self setFrameOfActivityView:asyVwOfPost.frame.size.height + asyVwOfPost.frame.origin.y + 10];
        int taggedUser =  [self setFramesOfTaggedUsers:asyVwOfPost.frame.size.height + asyVwOfPost.frame.origin.y + 35];
        imgVwBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, heightPostImg + lblComment.frame.origin.y + [Constant heightOfCellInTableVw] + 45 + taggedUser);
            //imgVwBackground.backgroundColor = [UIColor redColor];
    } else {

        [self setFrameOfActivityView:lblComment.frame.size.height + lblComment.frame.origin.y + 10];
        int taggedUser =  [self setFramesOfTaggedUsers:lblComment.frame.size.height + lblComment.frame.origin.y + 40];
        imgVwBackground.frame = CGRectMake(0, 0, imgVwBackground.frame.size.width, lblComment.frame.size.height + (lblComment.frame.origin.y + 45) + taggedUser);
    }
    
 /*   if (objUserInfo.postImg.length != 0) {

        asyVwOfPost.hidden = NO;
        asyVwOfPost.frame = CGRectMake(0, heightPostImg + lblComment.frame.origin.y + 3, [Constant widthOfIPhoneView],  [Constant widthOfIPhoneView]);
        imgVwLagrePostImage.frame = CGRectMake(0, heightPostImg + lblComment.frame.origin.y + 3,  [Constant widthOfIPhoneView],  [Constant widthOfIPhoneView]);
            // asyVwOfPost.imageURL = [NSURL URLWithString:objUserInfo.postImg];
        [asyVwOfPost sd_setImageWithURL:[NSURL URLWithString:objUserInfo.postImg] placeholderImage:nil];
        asyVwOfPost.backgroundColor = [UIColor clearColor];

        btnShowImageOrVideo.frame = asyVwOfPost.frame;
        [self setFrameOfActivityView:asyVwOfPost.frame.size.height + asyVwOfPost.frame.origin.y + 10];
        int taggedUser =  [self setFramesOfTaggedUsers:asyVwOfPost.frame.size.height + asyVwOfPost.frame.origin.y + 35];
        imgVwBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, heightPostImg + lblComment.frame.origin.y + [Constant widthOfIPhoneView] + 45 + taggedUser);
            //imgVwBackground.backgroundColor = [UIColor redColor];
    } else {

        [self setFrameOfActivityView:lblComment.frame.size.height + lblComment.frame.origin.y + 10];
        int taggedUser =  [self setFramesOfTaggedUsers:lblComment.frame.size.height + lblComment.frame.origin.y + 40];
        imgVwBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, lblComment.frame.size.height + (lblComment.frame.origin.y + 45) + taggedUser);
    }*/

    [self showActivityVw]; //show activity

    if ((self.view.frame.size.height - (imgVwBackground.frame.size.height+64)) > 235) {
         scrollVwShowComment.contentSize = CGSizeMake(320, (imgVwBackground.frame.size.height + (self.view.frame.size.height - (imgVwBackground.frame.size.height+64))));
    } else {
         scrollVwShowComment.contentSize = CGSizeMake(320, (imgVwBackground.frame.size.height + 235)); //235));
    }


    if (objUserInfo.postImg.length != 0) {

        tbleVwComment.frame = CGRectMake(0, imgVwBackground.frame.size.height+1, [Constant widthOfIPhoneView], scrollVwShowComment.contentSize.height - (imgVwBackground.frame.size.height+45));
    } else {

        NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);

        int height;
        if (IS_IPHONE_6_IOS8) {
            height = 667.0;
        } else if (IS_IPHONE_6P_IOS8) {
            height = 736.0;
        } else {
            height = 568;
        }
        NSLog(@"%f",MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width));
        CGRect frame = tbleVwComment.frame;
        frame.origin.y = imgVwBackground.frame.size.height+2;
        frame.size.height = (height - (imgVwBackground.frame.size.height+ 5 + imgVwNavigation.frame.size.height +44));
        tbleVwComment.frame = frame;
    }

    NSLog(@"** %f", vwOfComment.frame.size.height);

    imgVwUser.frame = CGRectMake(10, imgVwBackground.frame.size.height+5 , 45, 45);

    if ([objUserInfo.type isEqualToString:@"video"]) {

        btnShowImageOrVideo.hidden = NO;
        [btnShowImageOrVideo setImage:[UIImage imageNamed:@"play-btn.png"] forState:UIControlStateNormal];
        [self.view bringSubviewToFront:btnShowImageOrVideo];
    }
}

#pragma mark - Set frame of tageed user button with tagged user list
/**************************************************************************************************
 Function to set frame of tageed user button with tagged user list
 **************************************************************************************************/

- (int)setFramesOfTaggedUsers:(int)yAxis {

    if (self.arryTaggedUser.count == 0 ) {
        return 0;
    }
    NSMutableString *strUserNameList = [[NSMutableString alloc]init];

    lblWith = [[UILabel alloc]initWithFrame:CGRectMake(2, yAxis+5, 40, 21)];
    lblWith.text = @"with";
    lblWith.textColor = [UIColor lightGrayColor];
    [imgVwBackground addSubview:lblWith];

    lblTaggesName = [[UILabel alloc]initWithFrame:CGRectMake(40, yAxis+5, self.view.frame.size.width - 50, 21)];
    lblTaggesName.textColor = [UIColor lightGrayColor];
    lblTaggesName.font = [UIFont fontWithName:@"Helvetica-Neue" size:13.0];
    lblTaggesName.textColor = [UIColor colorWithRed:90/256.0f green:108/256.0f blue:168/256.0f alpha:1.0];
    [imgVwBackground addSubview:lblTaggesName];

    UIButton *btnTaggedUser = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTaggedUser.frame = CGRectMake(40, yAxis+5, self.view.frame.size.width - 50, 30);
    [btnTaggedUser addTarget:self action:@selector(taggedUserBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [imgVwBackground addSubview:btnTaggedUser];

    for (UserInfo *userInfo  in self.arryTaggedUser) {
        NSString *strName = userInfo.userName;
        NSString *strAppendName = [NSString stringWithFormat:@"%@,", strName];
        [strUserNameList appendString:strAppendName];
    }

    lblTaggesName.text = strUserNameList;

    return 30;
}

#pragma mark - Tagged user btn tapped
/**************************************************************************************************
 Function to show tagged user list
 **************************************************************************************************/

- (void)taggedUserBtnTapped {

    [vwTaggedUser setHidden:NO];
    [self.view bringSubviewToFront:vwTaggedUser];
}

#pragma mark - More btn tapped
/**************************************************************************************************
 Function to show option on more btn
 **************************************************************************************************/

- (IBAction)moreBtnTapped:(id)sender {

    if([self.userInfo.userSocialType isEqualToString:@"Twitter"]) {

        [self.view bringSubviewToFront:btnBlock];
        [btnBlock setHidden:NO];
        btnBlock.frame = CGRectMake(btnMoreTweet.frame.origin.x - 30, btnMoreTweet.frame.origin.y+30, 60, 30);
    } else {

        if (self.userInfo.fromId.integerValue == userProfile.userId.integerValue) {

            [self.view bringSubviewToFront:btnDelete];
            [btnDelete setHidden:NO];
            btnDelete.frame = CGRectMake(btnMoreTweet.frame.origin.x - 30, btnMoreTweet.frame.origin.y+30, 60, 30);
        }
    }
}

#pragma mark - Block btn tapped
/**************************************************************************************************
 Function to block user with all post
 **************************************************************************************************/

- (IBAction)blockTweetPost:(id)sender {

    NSString *strUser = [NSString stringWithFormat:@"Are you sure to block @%@ ?", self.userInfo.userName];
    UIAlertView *alertVw = [[UIAlertView alloc]initWithTitle:@"Block" message:strUser delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil];
    [alertVw show];
}

#pragma mark - UIAlert view Delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {

        btnBlock.hidden = YES;
        return;
    }

    NSDictionary *param = @{@"screen_name":self.userInfo.screenName,
                            @"skip_status":@"1"};

    NSString *strFavourateUrl = [NSString stringWithFormat:TWITTER_BLOCK_USER];
    NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
                                  URL:requestURL parameters:param];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error)
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

#pragma mark - Mute btn tapped
/**************************************************************************************************
 Function to mute twitter user
 **************************************************************************************************/

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

    [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error) {

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

#pragma mark - Dlete post of fb
/**************************************************************************************************
 Function to delete post of fb
 **************************************************************************************************/

- (IBAction)deleteFBComment:(id)sender {
    
    [btnDelete setHidden:YES];
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
                                       NSLog(@"%@",error.description);

                                  if (!error) {

                                      NSLog(@"%@", result);
                                      [self.navigationController popViewControllerAnimated:YES];
                                  } else {

                                       [Constant showAlert:@"Message" forMessage:@"You can only delete those post, which are post by app."];
                                  }
                              }];
        }
    }];
}

/*
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
 */

#pragma mark - User profile btn tapped
/**************************************************************************************************
 Function to show user profile
 **************************************************************************************************/

- (IBAction)userProfileBtnTapped:(id)sender{

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
    vwController.userInfo = self.userInfo;
    [self.navigationController pushViewController:vwController animated:YES];
}

#pragma mark - Set frames of activity
/**************************************************************************************************
 Function to frame of activities
 **************************************************************************************************/

- (void)setFrameOfActivityView:(NSInteger)yAxis {

    if(yAxis < 50) {
        yAxis = 53;
    }

    int appendXAxis;
    int extraGap;

    if (IS_IPHONE5){
        appendXAxis = 0;
    } else  if (IS_IPHONE_6_IOS8) {
        appendXAxis = 15;
    } else {
        appendXAxis = 50;
        extraGap = 20;
    }

    [imgVwOfComentFb setFrame:CGRectMake(imgVwOfComentFb.frame.origin.x + appendXAxis, yAxis, 20, 21)];
    [imgVwOfLikeFb setFrame:CGRectMake(imgVwOfLikeFb.frame.origin.x, yAxis, 20, 21)];
    [btnCommentFb setFrame:CGRectMake(btnCommentFb.frame.origin.x + appendXAxis, yAxis+2,  btnCommentFb.frame.size.width,  btnCommentFb.frame.size.height)];
    [btnLike setFrame:CGRectMake(btnLike.frame.origin.x, yAxis+2, btnLike.frame.size.width, btnLike.frame.size.height)];
    [lblFBOrInstCommentCount setFrame:CGRectMake(lblFBOrInstCommentCount.frame.origin.x + appendXAxis, yAxis+2, lblFBOrInstCommentCount.frame.size.width, lblFBOrInstCommentCount.frame.size.height)];
    [lblFBOrInstLikeCount setFrame:CGRectMake(lblFBOrInstLikeCount.frame.origin.x, yAxis+2, lblFBOrInstLikeCount.frame.size.width, lblFBOrInstLikeCount.frame.size.height)];
    [btnShare setFrame:CGRectMake(btnShare.frame.origin.x, yAxis, btnShare.frame.size.width, btnShare.frame.size.height)];

    [imgVwOfLikeInstagram setFrame:CGRectMake(imgVwOfLikeInstagram.frame.origin.x, yAxis, 20, 20)];

    [lblRetweet setFrame:CGRectMake(lblRetweet.frame.origin.x + appendXAxis + 20, yAxis, lblRetweet.frame.size.width, lblRetweet.frame.size.height)];
    [lblFavourite setFrame:CGRectMake(lblFavourite.frame.origin.x+appendXAxis, yAxis, lblFavourite.frame.size.width, lblFavourite.frame.size.height)];

    [btnFavourite setFrame:CGRectMake(btnFavourite.frame.origin.x+appendXAxis, yAxis, btnFavourite.frame.size.width, btnFavourite.frame.size.height)];
    [btnReply setFrame:CGRectMake(btnReply.frame.origin.x, yAxis, btnReply.frame.size.width, btnReply.frame.size.height)];
    [btnRetweet setFrame:CGRectMake(btnRetweet.frame.origin.x + appendXAxis + 20, yAxis,  btnRetweet.frame.size.width,  btnRetweet.frame.size.height)];
    [btnMoreTweet setFrame:CGRectMake(btnMoreTweet.frame.origin.x, yAxis,  btnMoreTweet.frame.size.width,  btnMoreTweet.frame.size.height)];
}

#pragma mark - Cancel btn tapped
/**************************************************************************************************
 Function to cancel view
 **************************************************************************************************/

- (IBAction)cancelBtnTapped:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Profile pic of post user
/**************************************************************************************************
 Function to set profile pic of post user
 **************************************************************************************************/

- (void)setProfilePicOfPostUser:(UserInfo *)userInfo  {

    if ([userInfo.userSocialType isEqualToString:@"Facebook"]) {

        dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(postImageQueue, ^{
            NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:self.postUserImg]];

            dispatch_async(dispatch_get_main_queue(), ^{

                UIImage *img = [UIImage imageWithData:image];
                UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
                imgVwPostUser.image = imgProfile;
            });
        });
    } else {

        dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(postImageQueue, ^{
            NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:userInfo.userProfileImg]];

            dispatch_async(dispatch_get_main_queue(), ^{

                UIImage *img = [UIImage imageWithData:image];
                UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
                imgVwPostUser.image = imgProfile;
            });
        });
    }
}

#pragma mark - Profile pic of login user
/**************************************************************************************************
 Function to set profile pic of login user
 **************************************************************************************************/

- (void)setProfilePic:(UserInfo *)userInfo  {

    userProfile = [UserProfile getProfile:userInfo.userSocialType];

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
    return [self.arryTaggedUser count]+1;
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

    if (indexPath.row < self.arryTaggedUser.count) {

        [activityIndicator stopAnimating];
        [activityIndicator setHidden:YES];

        UserInfo *userTagged = [self.arryTaggedUser objectAtIndex:indexPath.row];
        cell.textLabel.text = userTagged.userName;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0];
    } else {

        [activityIndicator setHidden:NO];
        [activityIndicator startAnimating];
        [cell addSubview:activityIndicator];

        if (nextTagedUrl.length != 0) {
            [self getMoreTaggedUser];
        }
    }

    return cell;
}

#pragma mark - UITable view Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == tbleVwComment) {

        UserComment *userComment = [self.arryComment objectAtIndex:indexPath.row];

        int widthOfComment;
        if (IS_IPHONE_6_IOS8) {
            widthOfComment = [Constant widthOfCommentLblOfTimelineAndProfile] + 50;
        } else if (IS_IPHONE_6P_IOS8) {
            widthOfComment = iPhone6_Plus_lbl_width;
        } else {
            widthOfComment = iPhone5_lbl_width;
        }

        NSString *string = userComment.userComment;
        CGRect rect = [string boundingRectWithSize:CGSizeMake(widthOfComment, 400)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                           context:nil];

        return (rect.size.height + 35);//183 is height of other fixed content
    }
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView == tbleVwTaggedUser) {

        UserInfo *userInfo = [self.arryTaggedUser objectAtIndex:indexPath.row];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShowOtherUserProfileViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"OtherUser"];
        vwController.userInfo = userInfo;
        [self.navigationController pushViewController:vwController animated:YES];
    }
}

#pragma mark - Set facebook configuration
/**************************************************************************************************
 Function to set facebook configuration
 **************************************************************************************************/

- (void)facebookConfiguration {

    [imgVwOfComentFb setHidden:NO];
    [imgVwOfLikeFb setHidden:NO];
    [btnCommentFb setHidden:NO];
    [btnLike setHidden:NO];
    [lblFBOrInstLikeCount setHidden:NO];
    [lblFBOrInstCommentCount setHidden:NO];
    [btnShare setHidden:NO];
    [btnMoreTweet setHidden:NO];
}

#pragma mark - Set twitter configuration
/**************************************************************************************************
 Function to set twitter configuration
 **************************************************************************************************/

- (void)twitterConfiguration  {

    [lblFavourite setHidden:NO];
    [lblRetweet setHidden:NO];
    [btnRetweet setHidden:NO];
    [btnFavourite setHidden:NO];
    [btnReply setHidden:NO];
    [btnMoreTweet setHidden:NO];
}

#pragma mark - Set instagram configuration
/**************************************************************************************************
 Function to set instagram configuration
 **************************************************************************************************/

- (void)instagramConfiguration  {

    [imgVwOfComentFb setHidden:NO];
    [imgVwOfLikeInstagram setHidden:NO];
    [btnCommentFb setHidden:NO];
    [btnLike setHidden:NO];
    [btnMoreTweet setHidden: NO];
    [lblFBOrInstLikeCount setHidden:NO];
    [lblFBOrInstCommentCount setHidden:NO];

    lblFBOrInstCommentCount.text = [NSString stringWithFormat:@"%@", self.userInfo.instagramCommentCount];
    lblFBOrInstLikeCount.text = [NSString stringWithFormat:@"%@",self.userInfo.instagramLikeCount];
}

#pragma mark - Show more tagged user
/**************************************************************************************************
 Function to show more tagged user
 **************************************************************************************************/

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
                                  NSLog(@"%@", [error debugDescription]);
                                  [self setCommentOfpostDetail:self.userInfo];
                              } else  {
                                  NSLog(@"%@", result);
                                  nextTagedUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];
                                  NSArray *arry = [result objectForKey:@"data"];
                                  [self.arryTaggedUser removeAllObjects];
                                  [self getTaggedUser:arry];
                                  [self setCommentOfpostDetail:self.userInfo];

                              }
                          }];
}

#pragma mark - Convert tagged user data in to model class
/**************************************************************************************************
 Function to convert tagged user data in to model class
 **************************************************************************************************/

- (void)getTaggedUser:(NSArray *)arryUser {

    for (NSDictionary *dictUser in arryUser) {

        if ([[dictUser valueForKey:@"name"] length] != 0) {

            UserInfo *userInfo = [[UserInfo alloc]init];
            userInfo.fromId = [dictUser valueForKey:@"id"];
            userInfo.userName = [dictUser valueForKey:@"name"];
            userInfo.userSocialType = @"Facebook";

            [self.arryTaggedUser addObject:userInfo];
        }
    }

    [tbleVwTaggedUser reloadData];
}

#pragma mark - More tagged user
/**************************************************************************************************
 Function to get more user
 **************************************************************************************************/

- (void)getMoreTaggedUser {

    //Get more data of feed
    NSURL *fbUrl = [NSURL URLWithString:sharedAppDelegate.nextFbUrl];
    fbTaggedUserRequest = [[NSMutableURLRequest alloc]initWithURL:fbUrl];
    connetionTaggedUser = [[NSURLConnection alloc]initWithRequest:fbTaggedUserRequest delegate:self];
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    if(connection == connFBLagreImage) {
         _responseData = [[NSMutableData alloc] init];
    } else {
        fbData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (connection == connFBLagreImage) {
        [_responseData appendData:data];
    } else {
        [fbData appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
        // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if (connection == connFBLagreImage) {

        [Constant hideNetworkIndicator];
        UIImage *image = [UIImage imageWithData:_responseData];

        if ([self.userInfo.type isEqualToString:@"video"]) {

        } else {
            asyVwOfPost.hidden = YES;
            imgVwLagrePostImage.hidden = NO;
            imgVwLagrePostImage.image = image;
        }

    } else {
        id result = [NSJSONSerialization JSONObjectWithData:fbData options:kNilOptions error:nil];
        NSLog(@"%@", result);
        nextTagedUrl = [[result objectForKey:@"paging"]valueForKey:@"next"];
        [self getTaggedUser:[result objectForKey:@"data"]];
    }
}

#pragma mark - Like fb post
/**************************************************************************************************
 Function to like fb post
 **************************************************************************************************/

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
                                    lblFBOrInstLikeCount.text = [NSString stringWithFormat:@"%i",lblFBOrInstLikeCount.text.integerValue +1];
                                  }
                              }];
    }];
}


#pragma mark - Unlike fb
/**************************************************************************************************
 Function to  unlike fb
 **************************************************************************************************/

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
                                          imgVwOfLikeFb.image = [UIImage imageNamed:@"Liked.png"];
                                      }];

                                      [btnLike setTitle:@"Like" forState:UIControlStateNormal];
                                      btnLike.titleLabel.textColor = [UIColor lightGrayColor];
                                      [btnLike removeTarget:self action:@selector(unlikedPost) forControlEvents:UIControlEventTouchUpInside];
                                      [btnLike addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
                                  }
                              }];
    }];
}

#pragma mark - Get fb post like count
/**************************************************************************************************
 Function to get fb post like count
 **************************************************************************************************/

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
                              }
    }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [btnDelete setHidden:YES]; //hide on tapped any where
    [vwTaggedUser setHidden:YES];

 /*   if ([self.userInfo.type isEqualToString:@"video"]) {

        [self playBtnTapped:nil];
        return;
    }
        // [self.view bringSubviewToFront:imgVwPostImage];

    [lblTaggesName setHidden:YES];
    [lblWith setHidden:YES];

    NSLog(@"touch ** ");
    UITouch *touch = [[event allTouches]anyObject];
    touchBegin = [touch locationInView:self.view];

    for (UIView *view in self.view.subviews) {

        if ([view isKindOfClass:[btnBlock class]] &&
            CGRectContainsPoint(view.frame, touchBegin)) {

        } else {
            [btnBlock setHidden:YES];
        }
    }*/
}


/*- (void)touchesMoved: (NSSet *)touches withEvent: (UIEvent *) event {

    NSLog(@"touch move ** ");

    UITouch *touch = [[event allTouches]anyObject];
    touchMove = [touch locationInView:self.view];

    if (touchMove.y > touchBegin.y) {

        NSLog(@"image show");
        [vwOfComment bringSubviewToFront:imgVwPostImage];
        [UIView animateWithDuration:0.5 animations:^{

            [imgVwPostImage setHidden:NO];
            [imgVwPostImage setFrame:CGRectMake(imgVwBackground.frame.origin.x, imgVwBackground.frame.origin.y, imgVwBackground.frame.size.width, imgVwBackground.frame.size.height-20)];

        }];

    } else {
        NSLog(@"not show");
        [UIView animateWithDuration:0.5 animations:^{

            [imgVwPostImage setHidden:YES];
            [imgVwPostImage setFrame:CGRectMake(50, 0, 320 ,320)];
        }];

    }
}


- (void)touchesEnded:(NSSet *)touches withEvent: (UIEvent *) event {

    [UIView animateWithDuration:0.4 animations:^{

        [imgVwPostImage setHidden:YES];
        [imgVwPostImage setFrame:CGRectMake(50, 0, 226,128)];
    }];
    [lblTaggesName setHidden:NO];
    [lblWith setHidden:NO];
}
*/

#pragma mark - show Like count

- (void)likeUserList:(NSString*)strCount {

    lblFBOrInstLikeCount.text = [NSString stringWithFormat:@"%lld", strCount.longLongValue];

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

#pragma mark - Play btn tapped
/**************************************************************************************************
 Function to play video
 **************************************************************************************************/

- (IBAction)playBtnTapped:(id)sender {

    UIStoryboard *storyBoard = [UIStoryboard  storyboardWithName:@"Main" bundle:nil];
    ShowImageOrVideoViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"ShowImageOrVideo"];
    viewController.userInfo = self.userInfo;
    if ([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {
        viewController.imgLarge = imgVwLagrePostImage.image;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Retweet btn tapped or not
/**************************************************************************************************
 Function to check retweet btn tapped or not
 **************************************************************************************************/

- (IBAction)retweetBtnPressOrNot:(id)sender {

    NSData *data1 = UIImagePNGRepresentation(btnRetweet.imageView.image);
    NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"Retweet1.png"]);

    if ([data1 isEqual:data2]) { //retweet
        [self retweetOnTwitter:nil];
    } else { //delete retweet
        [self deleteRetweet:nil];
    }
}

#pragma mark - Favourite btn tapped or not
/**************************************************************************************************
 Function to check favourite btn tapped or not
 **************************************************************************************************/

- (IBAction)favouriteBtnPressOrNot:(id)sender {

    NSData *data1 = UIImagePNGRepresentation(btnFavourite.imageView.image);
    NSData *data2 = UIImagePNGRepresentation([UIImage imageNamed:@"Favourite1.png"]);

    if ([data1 isEqual:data2]) { //favoutrite
        [self favouriteOnTwitterPost:nil];
    } else { //delete retweet
        [self deleteFavouriteOnTwitterPost:nil];
    }
}

#pragma mark - Retweet on twitter
/**************************************************************************************************
 Function to retweet on twitter
 **************************************************************************************************/

- (void)retweetOnTwitter:(id)sender {

    NSString *strRetweet = [NSString stringWithFormat:TWITTER_CREATE_RETWEERT, self.userInfo.statusId];
        //api.twitter.com/1.1/statuses/update.json"];

    NSURL *requestURL = [NSURL URLWithString:strRetweet];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
                                  URL:requestURL parameters:nil];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse*urlResponse, NSError *error) {

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
                   [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                           // animate it to the identity transform (100% scale)
                       btnRetweet.transform = CGAffineTransformIdentity;
                   } completion:^(BOOL finished){
                       [btnRetweet setImage:[UIImage imageNamed:@"Retweet_active.png"]forState:UIControlStateNormal];//selected
                       [Constant showAlert:@"Success" forMessage:@"Retweet has post successfully."];
                       [Constant hideNetworkIndicator];
                   }];
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                    //[Constant showAlert:@"Message" forMessage:@"Error to retweet"];
                   [Constant hideNetworkIndicator];
               });
           }
       }
     }];
}

#pragma mark - Remove retweet on twitter
/**************************************************************************************************
 Function to remove retweet on twitter
 **************************************************************************************************/

- (void)deleteRetweet:(id)sende {

    NSString *strFavourateUrl = [NSString stringWithFormat:TWITTER_DELETE_RETWEET ,self.userInfo.statusId];

    NSURL *requestURL = [NSURL URLWithString:strFavourateUrl];
    SLRequest *timelineRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
                                  URL:requestURL parameters:nil];

    timelineRequest.account = sharedAppDelegate.twitterAccount;

    [timelineRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error) {

//         if (<#condition#>) {
//             <#statements#>
//         }
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
                   [btnRetweet setImage:[UIImage imageNamed:@"Retweet1.png"] forState:UIControlStateNormal];//deselected
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [Constant hideNetworkIndicator];
               });
           }
       }
     }];
}

#pragma mark - Favourite on twitter
/**************************************************************************************************
 Function to favourite on twitter
 **************************************************************************************************/

- (void)favouriteOnTwitterPost:(id)sender {

    NSNumber * myNumber =[NSNumber numberWithLongLong:[self.userInfo.statusId longLongValue]];

    NSDictionary *param = @{@"id": myNumber};

        //[NSString stringWithFormat:@"http://api.twitter.com/1/favorites/create/%d.json", tweetID];

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
                   [Constant hideNetworkIndicator];
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
                   [Constant hideNetworkIndicator];
               });
           }
       }
     }];
}

#pragma mark - Delete favourite on twitter
/**************************************************************************************************
 Function to delete favourite on twitter
 **************************************************************************************************/

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
                   [Constant hideNetworkIndicator];
                   [btnFavourite setImage:[UIImage imageNamed:@"Favourite1.png"] forState:UIControlStateNormal];//deselected
               });
           } else {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [Constant hideNetworkIndicator];
               });
           }
       }
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

#pragma mark - Post comment on post in fb and twitter
/**************************************************************************************************
 Function to post comment on post in fb and twitter
 **************************************************************************************************/

- (IBAction)giveCommentByUser:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GiveCommentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"givecomment"];
    viewController.userInfo = self.userInfo;
    viewController.imgPostImg = imgVwLagrePostImage.image;
    viewController.strPostUserProfileUrl = self.postUserImg;
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark - Get large image of facebook
/**************************************************************************************************
 Function to get large image of facebook
 **************************************************************************************************/

- (void)getLargeImageOfFacebook {

    NSString *strUrl =  [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",self.userInfo.objectIdFB];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    connFBLagreImage = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (IBAction)postBtnTapped:(id)sender {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    vwController = (PostStatusViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"PostStatusViewController"];
    vwController.strPOstSocialType = self.userInfo.userSocialType;
    [self.navigationController pushViewController:vwController animated:YES];
        // [self performSegueWithIdentifier:@"poststatus" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"poststatus"]){
        vwController = [segue destinationViewController];
    }
}

@end

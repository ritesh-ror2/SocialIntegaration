//
//  GiveCommentViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface GiveCommentViewController : UIViewController <UITextViewDelegate> {

    IBOutlet UIImageView *imgVwProfile;
    IBOutlet UIImageView *imgVwbackg;
    IBOutlet UILabel *lblHeading;
    IBOutlet UILabel *lblNavHeading;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIButton *btnPost;
    IBOutlet UIButton *btnShowImageOrVideo;

    IBOutlet UIView *vwOfComment;
    IBOutlet UIImageView *imgVwPostUser;
    IBOutlet UILabel *lblComment;
    IBOutlet UIImageView *imgVwLagrePostImage;
    IBOutlet UIImageView *asyVwOfPost;
    IBOutlet UIImageView * imgVwBackground;
    IBOutlet UILabel *lblName;


    IBOutlet UIScrollView *scrollVwShowComment;
}

@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) NSString *strPostUserProfileUrl;
@property (nonatomic, strong) UIImage *imgPostImg;
@property (nonatomic, strong) IBOutlet UITextView *txtVwGiveComment;


@end

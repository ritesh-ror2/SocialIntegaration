//
//  ShowOtherUserProfileViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 20/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface ShowOtherUserProfileViewController : UIViewController {

    IBOutlet UIImageView *imgVwBgImg;
    IBOutlet UIImageView *ImgVwProfile;
    IBOutlet UIImageView *ImgVwCircle;
    IBOutlet UIImageView *imgVwLine1;
    IBOutlet UIImageView *imgVwLine2;

    IBOutlet UILabel *lblFollower;
    IBOutlet UILabel *lblFollowing;
    IBOutlet UILabel *lblTweet;
    IBOutlet UILabel *lblFolloweCount;
    IBOutlet UILabel *lblFolloeingCount;
    IBOutlet UILabel *lblTweetCount;
    IBOutlet UILabel *lblName;

    IBOutlet UIButton *btnRequestOrFollow;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgVwBorderMask;

@property (nonatomic, strong) UserInfo *userInfo;

@end

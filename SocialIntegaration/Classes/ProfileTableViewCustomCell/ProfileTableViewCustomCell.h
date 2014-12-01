//
//  ProfileTableViewCustomCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "AsyncImageView.h"

@interface ProfileTableViewCustomCell : UITableViewCell {

    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblSocialType;
    IBOutlet UILabel *lblText;
    IBOutlet UILabel *lblTime;
    IBOutlet UIImageView *imgVwOfUserProfile;
    IBOutlet AsyncImageView *imgVwPostImg;
    IBOutlet UIButton *btnPlay;
    IBOutlet UITextView *txtVwMessage;

    IBOutlet UIImageView *imgVwOfLikeFb;
    IBOutlet UIImageView *imgVwOfComentFb;
    IBOutlet UILabel *lblCommentFb;
    IBOutlet UILabel *lblLike;
    IBOutlet UILabel *lblFbLikeCount;

    IBOutlet UIButton *btnReply;
    IBOutlet UIButton *btnRetweet;
    IBOutlet UIButton *btnFavourate;
    IBOutlet UIButton *btnMoreTweet;
    IBOutlet UILabel *lblTweet;
    IBOutlet UILabel *lblFavourate;
    IBOutlet UIButton *btnProfile;

    IBOutlet UIImageView *imgVwOfLikeInstagram;
    UIActivityIndicatorView *spinner;
}

- (void)setValueInSocialTableViewCustomCell:(UserInfo *)objUserInfo;

@end

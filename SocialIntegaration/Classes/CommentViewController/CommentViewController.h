//
//  CommentViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "AsyncImageView.h"

@interface CommentViewController : UIViewController {

    IBOutlet UIView *vwOfComment;
    IBOutlet UIImageView *imgVwPostUser;
    IBOutlet UILabel *lblComment;
    IBOutlet UIImageView *imgVwUser;
    IBOutlet AsyncImageView *asyVwOfPost;
    IBOutlet UIImageView *imgVwNavigation;
    IBOutlet UIImageView * imgVwBackground;

    IBOutlet UIButton *btnRight;
    IBOutlet UIButton *btnLeft;
    IBOutlet UILabel *lblHeading;

    IBOutlet UIScrollView *scrollVw;
    IBOutlet UITableView *tbleVwTagList;

    IBOutlet UIImageView *imgVwOfLikeFb;
    IBOutlet UIImageView *imgVwOfComentFb;
    IBOutlet UIButton *btnCommentFb;
    IBOutlet UILabel *lblLike;

    IBOutlet UIImageView *imgVwOfReply;
    IBOutlet UIImageView *imgVwOfTweet;
    IBOutlet UIImageView *imgVwOfFavourate;
    IBOutlet UILabel *lblReply;
    IBOutlet UIButton *btnTweet;
    IBOutlet UILabel *lblFavourate;

    IBOutlet UIPageControl *pageControl;
    IBOutlet UIImageView *imgVwOfLikeInstagram;

    IBOutlet UITableView *tbleVwComment;
}

@property (nonatomic, strong)UserInfo *userInfo;
@property (nonatomic, strong)NSString *postUserImg;

@end
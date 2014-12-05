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
#import "ScrollVwOfComment.h"

@interface CommentViewController : UIViewController {

    IBOutlet UIView *vwOfComment;
    IBOutlet UIImageView *imgVwPostUser;
    IBOutlet UILabel *lblComment;
    IBOutlet UIImageView *imgVwUser;
    IBOutlet UIImageView *imgVwLagrePostImage;
    IBOutlet AsyncImageView *asyVwOfPost;
    IBOutlet UIImageView *imgVwNavigation;
    IBOutlet UIImageView * imgVwBackground;
    IBOutlet UILabel *lblName;

    IBOutlet UIButton *btnRight;
    IBOutlet UIButton *btnLeft;
    IBOutlet UILabel *lblHeading;

    IBOutlet UITableView *tbleVwTagList;
    IBOutlet UIImageView *imgVwOfLikeInstagram;

    //FB
    IBOutlet UIImageView *imgVwOfLikeFb;
    IBOutlet UIImageView *imgVwOfComentFb;
    IBOutlet UIButton *btnCommentFb;
    IBOutlet UILabel *lblFBOrInstLikeCount;
    IBOutlet UIButton *btnLike;
    IBOutlet UILabel *lblFBOrInstCommentCount;
    IBOutlet UIButton *btnShare;
    IBOutlet UIButton *btnDelete;

    //twitter
    IBOutlet UIButton *btnRetweet;
    IBOutlet UIButton *btnReply;
    IBOutlet UIButton *btnFavourite;
    IBOutlet UIButton *btnMoreTweet;
    IBOutlet UIButton *btnBlock;

    IBOutlet UILabel *lblRetweet;
    IBOutlet UILabel *lblReply;
    IBOutlet UILabel *lblFavourite;

    IBOutlet ScrollVwOfComment *scrollVwShowComment;

    IBOutlet UIButton *btnShowImageOrVideo;

    IBOutlet UITableView *tbleVwComment;
}

@property (nonatomic, strong)UserInfo *userInfo;
@property (nonatomic, strong)NSString *postUserImg;

@end

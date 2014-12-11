//
//  ShareCommentAndMessageViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 26/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"
#import "UserProfile+DatabaseHelper.h"

@interface ShareCommentAndMessageViewController : UIViewController {

    IBOutlet UILabel *lblFbHeading;
    IBOutlet UILabel *lblTwitterHeading;

    IBOutlet UIImageView *imgVwFB;
    IBOutlet UIImageView *imgVwTwitter;
    IBOutlet UIImageView *imgVwFBUserProfile;
    IBOutlet UIImageView *imgVwTwitterUserProfile;

    IBOutlet UIButton *btnTwitterPost;

    IBOutlet UILabel *lblComment;
    IBOutlet UILabel *lblCommentTwitter;
    IBOutlet UIPageControl *pageControl;
}

@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollVwComposre;
@property (nonatomic, strong) IBOutlet UIView *vwFB;
@property (nonatomic, strong) IBOutlet UIView *vwTwitter;
@property (nonatomic, strong) IBOutlet UITextView *txtVwFB;
@property (nonatomic, strong) IBOutlet UITextView *txtVwTwitter;
@property (nonatomic, strong) IBOutlet NSString *strShareOrMessage;
@property (nonatomic, strong) IBOutlet UITableView *tbleVwUser;

@end

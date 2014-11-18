//
//  GiveCommentViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface GiveCommentViewController : UIViewController {

    IBOutlet UITextView *txtVwCommnet;
    IBOutlet UIImageView *imgVwProfile;
    IBOutlet UIImageView *imgVwbackg;
    IBOutlet UILabel *lblHeading;
    IBOutlet UILabel *lblNavHeading;
    IBOutlet UINavigationBar *navBar;
    IBOutlet UIButton *btnPost;
}

@property (nonatomic, strong) UserInfo *userInfo;

@end

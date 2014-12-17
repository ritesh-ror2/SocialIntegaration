//
//  PostStatusViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 17/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostStatusViewController : UIViewController {

    IBOutlet UILabel *lblHeading;
    IBOutlet UIImageView *imgVeNavbar;
    IBOutlet UIImageView *imgVwOfUserProfile;
    IBOutlet UILabel *lblComment;
}


@property (nonatomic, strong) IBOutlet UITextView *txtVwPost;
@property (nonatomic, strong) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) IBOutlet UITableView *tbleVwUser;
@property (nonatomic, strong) NSString *strPOstSocialType;

@end

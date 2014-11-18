//
//  InstagramProfileViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstagramProfileViewController : UIViewController <IGSessionDelegate, IGRequestDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imgVwFBBackground;
@property (nonatomic, weak) IBOutlet UIImageView *imgVwProfileImg;

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblUserFollowing;
@property (nonatomic, weak) IBOutlet UILabel *lblUserFollowes;
@property (nonatomic, weak) IBOutlet UILabel *lblUserPost;
@property (nonatomic, weak) IBOutlet UILabel *lblStatus;

@property (nonatomic, strong) IBOutlet UITableView *tbleVwInstagramPost;

@property (nonatomic, strong) NSString *strUserText;
@property (nonatomic, strong) NSString *strUserName;

@property (nonatomic)NSUInteger index;

@end
//
//  ProfileViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController{

    IBOutlet UIButton *btnEdit;
    IBOutlet UIButton *btnRequest;
}

@property (nonatomic, weak) IBOutlet UIImageView *imgVwFBBackground;
@property (nonatomic, weak) IBOutlet UIImageView *imgVwProfileImg;
@property (nonatomic, weak) IBOutlet UIImageView *imgVwBorderMask;

@property (nonatomic, weak) IBOutlet UILabel *lblUserName;
@property (nonatomic, weak) IBOutlet UILabel *lblUserFrdList;

@property (nonatomic, strong) IBOutlet UITableView *tbleVwFeeds;

@property (nonatomic, strong) NSString *strUserText;
@property (nonatomic, strong) NSString *strUserName;

@property (nonatomic)NSUInteger index;

@property (nonatomic, strong) IBOutlet UIButton *btnRequest;
@property (nonatomic, strong) IBOutlet UIButton *btnEdit;

@property (nonatomic, strong) UINavigationController *navController;

@end

//
//  CustomTableCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface CustomTableCell : UITableViewCell {

    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblSocialType;
    IBOutlet UILabel *lblText;
    IBOutlet UILabel *lblTime;
    IBOutlet UIImageView *imgVwOfUserProfile;
    IBOutlet UIImageView *imgVwPostImg;
    IBOutlet UIButton *btnPlay;
    IBOutlet UITextView *txtVwMessage;
}

- (void)setValueInSocialTableViewCustomCell:(UserInfo *)objUserInfo;

@end

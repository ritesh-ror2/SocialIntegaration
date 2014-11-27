//
//  UserNotificationCustomCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserNotification.h"

@interface UserNotificationCustomCell : UITableViewCell {

    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblType;
    IBOutlet UILabel *lblName;
    IBOutlet UIImageView *imgVwProfile;
}


- (void)setNotificationIntableView:(UserNotification *)userNotification;

@end

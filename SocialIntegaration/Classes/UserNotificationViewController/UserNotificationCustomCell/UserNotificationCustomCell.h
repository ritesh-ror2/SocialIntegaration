//
//  UserNotificationCustomCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserNotification.h"

@protocol UserNotificationDelegate <NSObject>

- (void)userProfileBtnTapped:(UserNotification*)userNotificationInfo;

@end


@interface UserNotificationCustomCell : UITableViewCell {

    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblType;
    IBOutlet UILabel *lblName;
    IBOutlet UIImageView *imgVwProfile;
    IBOutlet UIButton *btnUserProfile;
}

@property (nonatomic, strong) UserNotification*userNotificationInfo;
@property (unsafe_unretained) id <UserNotificationDelegate> delegate;

- (void)setNotificationIntableView:(UserNotification *)userNotification;

@end

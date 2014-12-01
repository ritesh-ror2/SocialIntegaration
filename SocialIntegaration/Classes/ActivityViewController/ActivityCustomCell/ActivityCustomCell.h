//
//  UserNotificationCustomCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserActivity.h"

@interface ActivityCustomCell : UITableViewCell {

    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblType;
}


- (void)setActivityLogIntableView:(UserActivity *)userActivity;

@end

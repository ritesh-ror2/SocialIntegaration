//
//  UserNotificationCustomCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ActivityCustomCell.h"
#import "NSDate+Helper.h"
#import "Constant.h"

@implementation ActivityCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setActivityLogIntableView:(UserActivity *)userActivity {

    NSString *strSubstring = [userActivity.activityLog substringToIndex: userActivity.activityLog.length - 1];
    NSString *string = [NSString stringWithFormat:@"%@ on %@", strSubstring, userActivity.activitySocialType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 100)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                      context:nil];

    lblTitle.frame = CGRectMake(10, 5, 280, rect.size.height);
    lblTime.text =  [Constant  calculateTimesBetweenTwoDates:userActivity.activityTime];

    NSMutableAttributedString * strAttribut = [[NSMutableAttributedString alloc] initWithString:string];

    //lblType.text = userNotification.notifType;

    if ([userActivity.activitySocialType isEqualToString: @"Facebook"]) {

        [strAttribut addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:92/256.0f green:103/256.0f blue:159/256.0f alpha:1.0] range:NSMakeRange(string.length - 8, 8)];
    } else if ([userActivity.activitySocialType isEqualToString: @"Twitter"]) {
        [strAttribut addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0] range:NSMakeRange(string.length - 7, 7)];
    } else {
        [strAttribut addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(string.length - 9, 9)];
    }

    lblTitle.attributedText = strAttribut;
}


@end

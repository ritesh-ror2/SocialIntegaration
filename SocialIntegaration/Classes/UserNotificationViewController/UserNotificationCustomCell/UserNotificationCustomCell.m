//
//  UserNotificationCustomCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "UserNotificationCustomCell.h"
#import "NSDate+Helper.h"
#import "Constant.h"

@implementation UserNotificationCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Set notification in list

- (void)setNotificationIntableView:(UserNotification *)userNotification {

    CGFloat extra = 0;
    if(IS_IPHONE_6_IOS8)
        extra = 25;
    else if(IS_IPHONE_6P_IOS8)
        extra = 60;


    lblName.text = userNotification.name;

    NSString *strSubstring = [userNotification.title substringToIndex: userNotification.title.length - 1];
    NSString *string = [NSString stringWithFormat:@"%@ on %@", strSubstring, userNotification.notifType];
    CGRect rect = [string boundingRectWithSize:CGSizeMake([Constant widthOfCommentLblOfTimelineAndProfile], 100)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}
                                      context:nil];

    lblTitle.frame = CGRectMake(55, 25, [Constant widthOfCommentLblOfTimelineAndProfile]-70, rect.size.height);
    
    lblTime.frame = CGRectMake([Constant widthOfCommentLblOfTimelineAndProfile] - extra, 5, 37, 21);
    lblTime.text =  [Constant  calculateTimesBetweenTwoDates:userNotification.time];

    NSMutableAttributedString * strAttribut = [[NSMutableAttributedString alloc] initWithString:string];

    //lblType.text = userNotification.notifType;

    if ([userNotification.notifType isEqualToString: @"Facebook"]) {

        [strAttribut addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:92/256.0f green:103/256.0f blue:159/256.0f alpha:1.0] range:NSMakeRange(string.length - 8, 8)];
        [self uploadProfileImage:userNotification];
    } else if ([userNotification.notifType isEqualToString: @"Twitter"]) {

        [strAttribut addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0] range:NSMakeRange(string.length - 7, 7)];
        [self setProfileImageOfTwitterAndInstagram:userNotification];
    } else {

        [strAttribut addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(string.length - 9, 9)];
        [self setProfileImageOfTwitterAndInstagram:userNotification];
    }

    lblTitle.attributedText = strAttribut;
}

#pragma mark - Set profile image of twitter and Instagram

- (void)setProfileImageOfTwitterAndInstagram:(UserNotification *)objUserNotify {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:objUserNotify.userImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwProfile.image = imgProfile;
        });
    });
}


#pragma mark - Set User profile images

- (void)uploadProfileImage:(UserNotification *)objUserNotify {

        // load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", objUserNotify.fromId]];
	dispatch_queue_t profileURLQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(profileURLQueue, ^{

        NSData *result = [NSData dataWithContentsOfURL:jsonURL];

        if (result) {

			NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:result
																	   options:NSJSONReadingMutableContainers
																		 error:NULL];
            NSLog(@"** %@", resultDict);

            NSString *strProfileImg = [[resultDict valueForKey:@"data"] valueForKey:@"url"];
            strProfileImg = strProfileImg;
            if (strProfileImg.length == 0) {
                strProfileImg = @"user-selected.png";
                UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed:strProfileImg] withMask:[UIImage imageNamed:@"list-mask.png"]];
                imgVwProfile.image = imgProfile;
                return ;
            }

            dispatch_queue_t userImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(userImageQueue, ^{

                NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strProfileImg]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    UIImage *img = [UIImage imageWithData:image];
                    UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
                    
                    imgVwProfile.image = imgProfile;
                });
            });
		}
	});
}

@end

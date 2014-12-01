//
//  DetailMessageShowCustomCellTableViewCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "DetailMessageShowCustomCellTableViewCell.h"
#import "Constant.h"
#import "NSDate+Helper.h"
#import <QuartzCore/QuartzCore.h>

@implementation DetailMessageShowCustomCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {

    imgVwArrow = [[UIImageView alloc]init];
    [self.contentView addSubview:imgVwArrow];
    [self.contentView sendSubviewToBack:imgVwArrow];

    imgVwBackground = [[UIImageView alloc]init];
    imgVwBackground.layer.cornerRadius = 5.0;
    imgVwBackground.clipsToBounds = YES;
    [self.contentView addSubview:imgVwBackground];

    lblMessage = [[UILabel alloc]init];
    lblMessage.textColor = [UIColor whiteColor];
    lblMessage.numberOfLines = 0;
    [self.contentView addSubview:lblMessage];

    imgVwUser = [[UIImageView alloc]init];
    [self.contentView addSubview:imgVwUser];

    lblTime = [[UILabel alloc]init];
    lblTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    lblTime.textColor = [UIColor lightGrayColor];
    lblTime.numberOfLines = 0;
    [self.contentView addSubview:lblTime];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDetailMessageOnTableView:(UserComment*)objComment withUserId:(NSString*)userId {

    if (objComment.userComment.length == 0) {
        return;
    }
    NSString *string = objComment.userComment;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(230, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    long isToday = [self calculateTimesBetweenTwoDates:objComment.time];

    NSString *strTime;
    if (isToday == 0) {
        strTime = [NSString stringWithFormat:@"Today %@",[self convertTime:[objComment.time substringFromIndex:10] ]];
    } else {
        NSString *strSubstrTime = [objComment.time substringToIndex:10];
        strTime = [NSString stringWithFormat:@"On %@",[self convertDateFormate:strSubstrTime]];
    }
    lblTime.text = strTime;

    if (![objComment.fromId isEqualToString:userId]) {

        lblMessage.text = objComment.userComment;
        lblMessage.backgroundColor = [UIColor clearColor];
        lblMessage.frame = CGRectMake(60, 5, rect.size.width, rect.size.height);

        lblTime.textAlignment = NSTextAlignmentLeft;
        lblTime.frame = CGRectMake(61, rect.size.height + 7,130 , 21);

        imgVwBackground.frame = CGRectMake(55, 3, rect.size.width+10, rect.size.height+6);
        imgVwBackground.backgroundColor = [UIColor colorWithRed:107/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];

        imgVwUser.frame = CGRectMake(5, 0, 40, 40);
        imgVwArrow.image = [UIImage imageNamed:@"arrow-blue.png"];
        imgVwArrow.frame = CGRectMake(50, 5, 7, 14);
    } else {

        lblMessage.text = objComment.userComment;
        lblMessage.frame = CGRectMake((263 - rect.size.width), 5, rect.size.width, rect.size.height+2);
        lblMessage.backgroundColor = [UIColor clearColor];

        lblTime.frame = CGRectMake((264 -130), rect.size.height + 7, 130 , 21);
        lblTime.textAlignment = NSTextAlignmentRight;

        imgVwBackground.frame = CGRectMake((258 - rect.size.width), 3, rect.size.width+10, rect.size.height+6);
        imgVwBackground.backgroundColor = [UIColor lightGrayColor];

        imgVwUser.frame = CGRectMake(275, 0, 40, 40);
        imgVwArrow.image = [UIImage imageNamed:@"arrow-gray.png"];
        imgVwArrow.frame = CGRectMake(265, 5, 7, 14);
    }
    [self uploadProfileImage:objComment];
    NSLog(@"%@", objComment.userComment);
}

- (NSString *)convertTime:(NSString*)time {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];

    NSDate *date = [dateFormatter dateFromString:time];

    [dateFormatter setDateFormat:@"hh:mm a"];

    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return formattedDate;
}

#pragma mark - Calculate time between two dates

- (long)calculateTimesBetweenTwoDates:(NSString *)strGivenDate {

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *toDate = [NSDate dateFromString:strDate];

    NSDate *fromDate = [NSDate dateFromString:strGivenDate];
    NSLog(@"%@  from %@", toDate, fromDate);

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit| NSHourCalendarUnit|NSDayCalendarUnit
                                                        fromDate:fromDate toDate:toDate options:0];
    long diffInDate = components.day;
    NSLog(@"%i", components.day);
    if (diffInDate != 0)  {
        return diffInDate;
    } else {
        return 0;
    }
}

- (NSString *)convertDateFormate:(NSString *)strDate {

    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formate dateFromString:strDate];

    [formate setDateFormat:@"dd-MM-yyyy"];
    NSString *strConvertDate = [formate stringFromDate:date];
    return strConvertDate;
}

/*- (NSString *)differenceBetweenDate:(NSString *)strGivenDate {

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *toDate = [NSDate dateFromString:strGivenDate];
//
    NSDate *fromDate = [NSDate dateFromStringInUserNotify:strGivenDate];
    NSLog(@"%@  from %@", toDate, fromDate);

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSMinuteCalendarUnit| NSHourCalendarUnit|NSDayCalendarUnit
                                                        fromDate:fromDate toDate:toDate options:0];
    int diffInDate = components.hour;
    NSString *strTime;

    if (diffInDate == 0)  {
        strTime = [NSString stringWithFormat:@"Before %d minute",diffInDate];
    } else {
        strTime = [NSString stringWithFormat:@"Before %d hour",diffInDate];
    }
    return strTime;
}
*/

- (void)uploadProfileImage:(UserComment *)objUserComment {

        // load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", objUserComment.fromId]];
	dispatch_queue_t profileURLQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(profileURLQueue, ^{
		NSData *result = [NSData dataWithContentsOfURL:jsonURL];
		if (result) {

			NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:result
																	   options:NSJSONReadingMutableContainers
																		 error:NULL];
            NSLog(@"** %@", resultDict);

            NSString *strProfileImg = [[resultDict valueForKey:@"data"] valueForKey:@"url"];
            if (strProfileImg.length == 0) {
                strProfileImg = @"user-selected.png";
                UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed:strProfileImg] withMask:[UIImage imageNamed:@"mask_message.png"]];
                imgVwUser.image = imgProfile;
                return ;
            }

            dispatch_queue_t userImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(userImageQueue, ^{

                NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strProfileImg]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    UIImage *img = [UIImage imageWithData:image];
                    UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"mask_message.png"]];

                    imgVwUser.image = imgProfile;
                });
            });
		}
	});
}

@end

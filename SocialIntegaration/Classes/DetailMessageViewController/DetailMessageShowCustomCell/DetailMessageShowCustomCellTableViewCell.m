//
//  DetailMessageShowCustomCellTableViewCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "DetailMessageShowCustomCellTableViewCell.h"
#import "Constant.h"
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

    //lblMessage.layer.borderWidth = 3.0;
    [self.contentView addSubview:lblMessage];

    imgVwUser = [[UIImageView alloc]init];
    [self.contentView addSubview:imgVwUser];
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
    if (![objComment.fromId isEqualToString:userId]) {

        lblMessage.text = objComment.userComment;
        lblMessage.backgroundColor = [UIColor clearColor];
        lblMessage.frame = CGRectMake(60, 5, rect.size.width, rect.size.height);

        imgVwBackground.frame = CGRectMake(55, 3, rect.size.width+10, rect.size.height+6);
        imgVwBackground.backgroundColor = [UIColor colorWithRed:107/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];

        imgVwUser.frame = CGRectMake(5, 0, 40, 40);
        imgVwArrow.image = [UIImage imageNamed:@"arrow-blue.png"];
        imgVwArrow.frame = CGRectMake(50, 5, 7, 14);
    } else {

        lblMessage.text = objComment.userComment;
        lblMessage.frame = CGRectMake((263 - rect.size.width), 5, rect.size.width, rect.size.height+2);
        lblMessage.backgroundColor = [UIColor clearColor];

        imgVwBackground.frame = CGRectMake((258 - rect.size.width), 3, rect.size.width+10, rect.size.height+6);
        imgVwBackground.backgroundColor = [UIColor lightGrayColor];

        imgVwUser.frame = CGRectMake(275, 0, 40, 40);
        imgVwArrow.image = [UIImage imageNamed:@"arrow-gray.png"];
        imgVwArrow.frame = CGRectMake(265, 5, 7, 14);
    }
    [self uploadProfileImage:objComment];
    NSLog(@"%@", objComment.userComment);
}

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

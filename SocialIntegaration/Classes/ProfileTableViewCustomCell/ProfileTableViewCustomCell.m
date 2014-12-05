//
//  ProfileTableViewCustomCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ProfileTableViewCustomCell.h"
#import "Constant.h"

@implementation ProfileTableViewCustomCell

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
}

#pragma mark - set value in table view

- (void)setValueInSocialTableViewCustomCell:(UserInfo *)objUserInfo  {

    lblName.text = objUserInfo.userName;
    lblTime.text =  [Constant  calculateTimesBetweenTwoDates:objUserInfo.time];

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    lblText.frame = CGRectMake(63, 53, 250, rect.size.height+2);
    lblText.text = objUserInfo.strUserPost;

    lblSocialType.text = objUserInfo.userSocialType;

    if ([objUserInfo.userSocialType isEqualToString: @"Facebook"]) {

        lblSocialType.textColor = [UIColor colorWithRed:92/256.0f green:103/256.0f blue:159/256.0f alpha:1.0];
        [self uploadProfileImage:objUserInfo]; //upload profile image
    } else if ([objUserInfo.userSocialType isEqualToString: @"Twitter"]) {

        lblSocialType.textColor = [UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0];
        [self setProfileImageOfTwitter:objUserInfo];
    } else {
        lblSocialType.textColor = [UIColor colorWithRed:93/256.0f green:122/256.0f blue:154/256.0f alpha:1.0];
        [self setProfileImageOfTwitter:objUserInfo];
    }
    btnPlay.hidden = YES;

    if (objUserInfo.postImg.length != 0) {

//        if (imgVwPostImg.image != nil) {
//            imgVwPostImg.image = nil;
//        }
        imgVwPostImg.frame = CGRectMake(imgVwPostImg.frame.origin.x,  lblText.frame.size.height + lblText.frame.origin.y, 250, 100);
        imgVwPostImg.hidden = NO;
        btnPlay.frame = imgVwPostImg.frame;
        
        [self setPostImageAndOfFB:objUserInfo];
    } else {
        imgVwPostImg.hidden = YES;
    }

    if ([objUserInfo.type isEqualToString:@"video"]) {
        btnPlay.hidden = NO;
    }
}

- (void)setProfileImageOfTwitter:(UserInfo *)objUserInfo {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:objUserInfo.userProfileImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwOfUserProfile.image = imgProfile;
        });
    });
}

- (void)setPostImageAndOfFB:(UserInfo *)objUserInfo {

     imgVwPostImg.imageURL = [NSURL URLWithString:objUserInfo.postImg];
}

- (void)uploadProfileImage:(UserInfo *)objUserInfo {

        // load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", objUserInfo.fromId]];
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
                UIImage *imgProfile = [Constant maskImage:[UIImage imageNamed:strProfileImg] withMask:[UIImage imageNamed:@"list-mask.png"]];
                imgVwOfUserProfile.image = imgProfile;
                return ;
            }

            dispatch_queue_t userImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(userImageQueue, ^{

                NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strProfileImg]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    UIImage *img = [UIImage imageWithData:image];
                    UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
                    
                    imgVwOfUserProfile.image = imgProfile;
                });
            });
		}
	});
}

@end

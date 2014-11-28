//
//  SearchCustomCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "SearchCustomCell.h"
#import "Constant.h"

@implementation SearchCustomCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

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

- (void)setSearchResultIntableView:(UserInfo *)userInfo {


    if (self.userInfo != nil) {
        self.userInfo = nil;
    }
    self.userInfo = userInfo;

    lblResult.text = userInfo.strUserName;

    NSString *string = userInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 100)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                       context:nil];

    btnFollow.hidden = YES;
    if ([userInfo.type isEqualToString:@"Keyword"]|| [userInfo.type isEqualToString:@"HashTag"]) {

        lblDescription.hidden = NO;
        lblResult.frame = CGRectMake(55, 5, 250, 21);
        lblDescription.text = userInfo.strUserPost;
        lblDescription.frame = CGRectMake(55, 27, 250, rect.size.height);
    } else {
        btnFollow.hidden = NO;
        lblResult.frame = CGRectMake(55, 10, 250, 21);
    }

    btnFollow.layer.cornerRadius = 5.0;
    btnFollow.layer.borderWidth = 0.5;
    btnFollow.layer.borderColor = [[UIColor lightGrayColor]CGColor];

        //follow or unfollow
    if (userInfo.isFollowing == 1){
        [btnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
        [btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }

    if ([userInfo.strUserSocialType isEqualToString:@"Facebook"]) {

        btnFollow.hidden = YES;
        [self uploadProfileImage:userInfo];
    } else if ([userInfo.strUserSocialType isEqualToString:@"Instagram"]) {
        btnFollow.hidden = YES;
        [self setProfileImageOfTwitterAndInstagram:userInfo];
    } else {
        [self setProfileImageOfTwitterAndInstagram:userInfo];
    }
}

#pragma mark - Set profile image of twitter and Instagram

- (void)setProfileImageOfTwitterAndInstagram:(UserInfo *)objUser{

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:objUser.strUserImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwUser.image = imgProfile;
        });
    });
}
- (IBAction)followBtnTapped:(id)sender {

    if ([btnFollow.titleLabel.text isEqualToString:@"Follow"]) {
        [btnFollow setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
         [btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(followOrNotFollow:withTitle:)]) {
        [self.delegate followOrNotFollow:self.userInfo withTitle:btnFollow.titleLabel.text];
    }
}

#pragma mark - Set User profile images

- (void)uploadProfileImage:(UserInfo *)objUser {

        // load profile picture
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=false&type=normal&width=110&height=110", objUser.fromId]];
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
                imgVwUser.image = imgProfile;
                return ;
            }

            dispatch_queue_t userImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(userImageQueue, ^{

                NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:strProfileImg]];

                dispatch_async(dispatch_get_main_queue(), ^{

                    UIImage *img = [UIImage imageWithData:image];
                    UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];

                    imgVwUser.image = imgProfile;
                });
            });
		}
	});
}

- (IBAction)showUserProfile:(id)sender {

    if ([self.delegate respondsToSelector:@selector(userProfileBtnTapped:)]) {
        [self.delegate userProfileBtnTapped:self.userInfo];
    }
}

@end

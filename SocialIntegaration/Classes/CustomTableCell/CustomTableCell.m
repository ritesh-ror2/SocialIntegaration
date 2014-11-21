//
//  CustomTableCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "CustomTableCell.h"
#import "Constant.h"

@implementation CustomTableCell

@synthesize customCellDelegate;

- (void)awakeFromNib {


    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureOnTableViewCell:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:tapGesture];

    [btnPlay addTarget:self action:@selector(handleTapGestureOnTableViewCell:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)handleSwipeGestureOnTableView: (UILongPressGestureRecognizer *)gesture {

    NSLog(@"%@", self.userInfo);
    if ([self.customCellDelegate respondsToSelector:@selector(didSelectRowWithObject:withFBProfileImg:)]) {
        [self.customCellDelegate didSelectRowWithObject:self.userInfo withFBProfileImg:self.strProfileImg];
    }
}

- (void)handleTapGestureOnTableViewCell: (UITapGestureRecognizer *)gesture {

    BOOL isAlreadyTapped;

    if([self.userInfo.strUserSocialType isEqualToString:@"Facebook"]) {
        if (lblName.textColor == [UIColor whiteColor]) {
            isAlreadyTapped = NO;
            [self handleSwipeGestureOnTableView:nil];
        } else {
            isAlreadyTapped = YES;
            [self didRowTapped:isAlreadyTapped];
        }

    } else  if([self.userInfo.strUserSocialType isEqualToString:@"Twitter"]) {

        if (lblName.textColor == [UIColor whiteColor]) {
            isAlreadyTapped = NO;
            [self handleSwipeGestureOnTableView:nil];

        } else {
            isAlreadyTapped = YES;
            [self didRowTapped:isAlreadyTapped];
        }
    } else {

        if (lblName.textColor == [UIColor whiteColor]) {

            isAlreadyTapped = NO;
            [self handleSwipeGestureOnTableView:nil];

        } else {
            isAlreadyTapped = YES;
            [self didRowTapped:isAlreadyTapped];
        }

            // [self InstagramCellConfiguration:YES];
    }
}

- (void)didRowTapped:(BOOL)isSelected {
    NSLog(@"%i", self.cellIndex);

    if ([self.customCellDelegate respondsToSelector:@selector(tappedOnCellToShowActivity:withCellIndex:withSelectedPrNot:)]) {
        [self.customCellDelegate tappedOnCellToShowActivity:self.userInfo withCellIndex:self.cellIndex withSelectedPrNot:isSelected];
    }
}

- (void)facebookCellConfiguration:(BOOL)isDisplay {

    NSLog(@"%hhd", isDisplay);

    if (isDisplay == YES) {

        [imgVwOfComentFb setHidden:NO];
        [imgVwOfLikeFb setHidden:NO];
        [lblCommentFb setHidden:NO];
        [lblLike setHidden:NO];
        [lblFbLikeCount setHidden:NO];

        self.contentView.backgroundColor = [UIColor colorWithRed:68/256.0f green:88/256.0f blue:156/256.0f alpha:1.0];
        lblText.textColor = [UIColor whiteColor];
        lblName.textColor = [UIColor whiteColor];
        btnMoreTweet.titleLabel.textColor = [UIColor whiteColor];
        lblTime.textColor = [UIColor whiteColor];
        lblSocialType.textColor = [UIColor whiteColor];
    } else {

        [imgVwOfComentFb setHidden:YES];
        [imgVwOfLikeFb setHidden:YES];
        [lblCommentFb setHidden:YES];
        [lblLike setHidden:YES];
        [lblFbLikeCount setHidden:YES];

        self.contentView.backgroundColor =  [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblName.textColor = [UIColor blackColor];
        lblTime.textColor = [UIColor darkGrayColor];
        lblSocialType.textColor = [UIColor blackColor];
    }
}

- (void)TwitterCellConfiguration:(BOOL)isDisplay  {

    if (isDisplay == YES) {

        [btnReply setHidden:NO];
        [btnRetweet setHidden:NO];
        [btnFavourate setHidden:NO];
        [lblTweet setHidden:NO];
        [btnMoreTweet setHidden:NO];
        [lblFavourate setHidden:NO];

        self.contentView.backgroundColor = [UIColor colorWithRed:109/256.0f green:171/256.0f blue:243/256.0f alpha:1.0];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"twitter-bg.png"]];
        lblText.textColor = [UIColor whiteColor];
        lblName.textColor = [UIColor whiteColor];
        lblTime.textColor = [UIColor whiteColor];
        lblSocialType.textColor = [UIColor whiteColor];
    } else {

        [btnReply setHidden:YES];
        [btnMoreTweet setHidden:YES];
        [btnRetweet setHidden:YES];
        [btnFavourate setHidden:YES];
        [lblTweet setHidden:YES];
        [lblFavourate setHidden:YES];

        self.contentView.backgroundColor = [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblName.textColor = [UIColor blackColor];
        lblTime.textColor = [UIColor darkGrayColor];
        lblSocialType.textColor = [UIColor blackColor];
    }
}

- (void)InstagramCellConfiguration:(BOOL)isDisplay  {

    if (isDisplay == YES) {

        [imgVwOfComentFb setHidden:NO];
        [imgVwOfLikeInstagram setHidden:NO];
        [lblCommentFb setHidden:NO];
        [lblLike setHidden:NO];

        self.contentView.backgroundColor = [UIColor colorWithRed:46/256.0f green:95/256.0f blue:136/256.0f alpha:1.0];
        lblText.textColor = [UIColor whiteColor];
        lblName.textColor = [UIColor whiteColor];
        lblTime.textColor = [UIColor whiteColor];
        lblSocialType.textColor = [UIColor whiteColor];
    } else {

        [imgVwOfComentFb setHidden:YES];
        [imgVwOfLikeInstagram setHidden:YES];
        [lblCommentFb setHidden:YES];
        [lblLike setHidden:YES];

        self.contentView.backgroundColor =  [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblName.textColor = [UIColor blackColor];
        lblTime.textColor = [UIColor darkGrayColor];
        lblSocialType.textColor = [UIColor blackColor];
    }
}

#pragma mark - Set value in table view

- (void)setValueInSocialTableViewCustomCell:(UserInfo *)objUserInfo forRow:(NSInteger)row withSelectedIndexArray:(NSMutableArray*)arrayOfSelectedIndex withSelectedCell:(NSMutableArray *)arrySelectedCell {

    if (self.userInfo != nil) {
        self.userInfo = nil;
    }

    self.userInfo = objUserInfo;
    self.cellIndex = row;

    lblName.text = objUserInfo.strUserName;
    lblTime.text =  [Constant  calculateTimesBetweenTwoDates:objUserInfo.struserTime];

    NSLog(@"%@", lblTime.text);

    NSString *string = objUserInfo.strUserPost;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(250, 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                       context:nil];

    lblText.frame = CGRectMake(63, 53, 250, rect.size.height);
    lblText.text = objUserInfo.strUserPost;

    lblSocialType.text = objUserInfo.strUserSocialType;

    if ([objUserInfo.strUserSocialType isEqualToString: @"Facebook"]) {

        lblSocialType.textColor = [UIColor colorWithRed:92/256.0f green:103/256.0f blue:159/256.0f alpha:1.0];
        [self uploadProfileImage:objUserInfo]; //upload profile image

    } else if ([objUserInfo.strUserSocialType isEqualToString: @"Twitter"]) {

        lblSocialType.textColor = [UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0];
        [self setProfileImageOfTwitterAndInstagram:objUserInfo];
    } else {
        lblSocialType.textColor = [UIColor colorWithRed:93/256.0f green:122/256.0f blue:154/256.0f alpha:1.0];
        [self setProfileImageOfTwitterAndInstagram:objUserInfo];
    }

    if (objUserInfo.strPostImg.length != 0) { //set post image

        imgVwPostImg.frame = CGRectMake(imgVwPostImg.frame.origin.x,  lblText.frame.size.height + lblText.frame.origin.y, 250, 100);
        imgVwPostImg.hidden = NO;
        btnPlay.frame = imgVwPostImg.frame;
        
        [self setPostImage:objUserInfo];
        [self setFrameOfActivityView:imgVwPostImg.frame.size.height + imgVwPostImg.frame.origin.y+10];
        btnPlay.hidden = NO;
        [btnPlay setImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
    } else {
        [self setFrameOfActivityView:lblText.frame.size.height + lblText.frame.origin.y+10];
    }

//    for (NSString *index in arrayOfSelectedIndex) {
//
//        if (row == index.integerValue) {
//            [self facebookCellConfiguration:YES];
//            break;
//        }
//    }

    [self getLikeCountOfFb];
    if ([self.userInfo.retweeted isEqualToString:@"1"]) {
        [btnRetweet setImage:[UIImage imageNamed:@"Retweet_active.png"] forState:UIControlStateNormal];//selected
    } else {
        [btnRetweet setImage:[UIImage imageNamed:@"Retweet.png"] forState:UIControlStateNormal];//deselected
    }

    if ([self.userInfo.favourated isEqualToString:@"1"]) {
        [btnFavourate setImage:[UIImage imageNamed:@"favourite_active.png"] forState:UIControlStateNormal];//selected
    } else {
        [btnFavourate setImage:[UIImage imageNamed:@"favourite.png"] forState:UIControlStateNormal];//deselected
    }
     
    if (arrayOfSelectedIndex.count != 0) {

        for (NSString *index in arrayOfSelectedIndex) {

            if (row == index.integerValue) {

                BOOL isSelected = [[arrySelectedCell objectAtIndex:row]boolValue];
                NSLog(@"%hhd", isSelected);
                if ([objUserInfo.strUserSocialType isEqualToString: @"Facebook"]) {
                    [self facebookCellConfiguration:isSelected];
                } else if ([objUserInfo.strUserSocialType isEqualToString: @"Twitter"]) {
                    [self TwitterCellConfiguration:isSelected];
                }
            }
        }
    }

    if ([objUserInfo.type isEqualToString:@"video"]) {
        [btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
    [self.contentView bringSubviewToFront:btnPlay];
    lblTweet.text = objUserInfo.retweetCount;
    lblFavourate.text = objUserInfo.favourateCount;
}

- (void)setFrameOfActivityView:(NSInteger)yAxis {

    [imgVwOfComentFb setFrame:CGRectMake(imgVwOfComentFb.frame.origin.x, yAxis, 20, 21)];
    [imgVwOfLikeFb setFrame:CGRectMake(imgVwOfLikeFb.frame.origin.x, yAxis, 20, 21)];
    [lblCommentFb setFrame:CGRectMake(lblCommentFb.frame.origin.x, yAxis, 80, 21)];
    [lblLike setFrame:CGRectMake(lblLike.frame.origin.x, yAxis, 70, 21)];
    [lblFbLikeCount setFrame:CGRectMake(lblFbLikeCount.frame.origin.x, yAxis, 70, 21)];

    [btnFavourate setFrame:CGRectMake(btnFavourate.frame.origin.x, yAxis, btnFavourate.frame.size.width, btnFavourate.frame.size.height)];
    [btnReply setFrame:CGRectMake(btnReply.frame.origin.x, yAxis, btnReply.frame.size.width, btnReply.frame.size.height)];
    [btnRetweet setFrame:CGRectMake(btnRetweet.frame.origin.x, yAxis, btnRetweet.frame.size.width, btnRetweet.frame.size.height)];
    [btnMoreTweet setFrame:CGRectMake(btnMoreTweet.frame.origin.x, yAxis, btnMoreTweet.frame.size.width, btnMoreTweet.frame.size.height)];

    [lblFavourate setFrame:CGRectMake(lblFavourate.frame.origin.x, yAxis+4, 70, 21)];
    [lblTweet setFrame:CGRectMake(lblTweet.frame.origin.x, yAxis+4, 70, 21)];

    [imgVwOfLikeInstagram setFrame:CGRectMake(imgVwOfLikeInstagram.frame.origin.x, yAxis, 20, 21)];
}

- (IBAction)profileBtnTapped:(id)sender {

    if ([self.customCellDelegate respondsToSelector:@selector(userProfileBtnTapped:)]) {
        [self.customCellDelegate userProfileBtnTapped:self.userInfo];
    }
}

#pragma mark - Set profile image of twitter and Instagram

- (void)setProfileImageOfTwitterAndInstagram:(UserInfo *)objUserInfo {

    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:objUserInfo.strUserImg]];

        dispatch_async(dispatch_get_main_queue(), ^{

            UIImage *img = [UIImage imageWithData:image];
            UIImage *imgProfile = [Constant maskImage:img withMask:[UIImage imageNamed:@"list-mask.png"]];
            imgVwOfUserProfile.image = imgProfile;
        });
    });
}

#pragma mark - Set post image

- (void)setPostImage:(UserInfo *)objUserInfo {

    imgVwPostImg.imageURL = [NSURL URLWithString:objUserInfo.strPostImg];
}

#pragma mark - Set User profile images

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
            self.strProfileImg = strProfileImg;
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


- (void)getLikeCountOfFb {

    NSDictionary *dictMessage = @{@"summary": @"true"};

    NSString *strUrl = [NSString stringWithFormat:@"/%@/likes",self.userInfo.objectIdFB];
    [FBRequestConnection startWithGraphPath:strUrl
                                 parameters:dictMessage
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (error){

                              } else {
                                 NSString *strLikeCount = [NSString stringWithFormat:@"%@",[[result objectForKey:@"summary"] valueForKey:@"total_count"]];
                                  lblFbLikeCount.text = strLikeCount;
                              }
                          }];
}
@end

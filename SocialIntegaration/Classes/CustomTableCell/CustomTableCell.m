//
//  CustomTableCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "CustomTableCell.h"
#import "Constant.h"
#import <QuartzCore/QuartzCore.h>

#define IS_IPHONE_6_IOS8      ([UIScreen mainScreen].bounds.size.height == 667)
#define IS_IPHONE_6P_IOS8 ([UIScreen mainScreen].bounds.size.height == 736)

@implementation CustomTableCell

@synthesize customCellDelegate;

#pragma mark - Cell Initialize

- (void)awakeFromNib {

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureOnTableViewCell:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:tapGesture];

    [btnPlay addTarget:self action:@selector(handleTapGestureOnTableViewCell:) forControlEvents:UIControlEventTouchUpInside];

    spinner.hidden = YES;
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(([Constant widthOfIPhoneView] - 37)/2, 5, 37, 37);
    [self.contentView addSubview:spinner];

    imgVwSeperatorLine.hidden = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];
}

#pragma mark - Delegates Function

/**************************************************************************************************
 Delegate to handle tapping of cell at first time
 **************************************************************************************************/

- (void)didRowTappedAtFirstTime:(BOOL)isSelected {

    if ([self.customCellDelegate respondsToSelector:@selector(tappedOnCellToShowActivity:withCellIndex:withSelectedPrNot:)]) {
        [self.customCellDelegate tappedOnCellToShowActivity:self.userInfo withCellIndex:self.cellIndex withSelectedPrNot:isSelected];
    }
}

/**************************************************************************************************
 Delegate to handle tapping of cell at second time
 **************************************************************************************************/

- (void)cellIsTappedAtSecondTime {

    if ([self.customCellDelegate respondsToSelector:@selector(didSelectRowWithObject:withFBProfileImg:)]) {
        [self.customCellDelegate didSelectRowWithObject:self.userInfo withFBProfileImg:self.strProfileImg];
    }
}

/**************************************************************************************************
 Delegate to handle when profile image is tapped
 **************************************************************************************************/

- (IBAction)profileBtnTapped:(id)sender {

    if ([self.customCellDelegate respondsToSelector:@selector(userProfileBtnTapped:)]) {
        [self.customCellDelegate userProfileBtnTapped:self.userInfo];
    }
}

#pragma mark - Handle tap gesture on cell
/**************************************************************************************************
 Function to handle tap gesture on cell
 **************************************************************************************************/

- (void)handleTapGestureOnTableViewCell:(UITapGestureRecognizer *)gesture {

    if([self.userInfo.userSocialType isEqualToString:@"Facebook"]) {

        if (self.isAlreadyTapped == YES) {

            self.isAlreadyTapped = NO;
            [self cellIsTappedAtSecondTime];
        } else {

            self.isAlreadyTapped = YES;
            [self didRowTappedAtFirstTime:self.isAlreadyTapped];
        }
    } else  if([self.userInfo.userSocialType isEqualToString:@"Twitter"]) {

        if (self.isAlreadyTapped == YES) {

            self.isAlreadyTapped = NO;
            [self cellIsTappedAtSecondTime];
        } else {

            self.isAlreadyTapped = YES;
            [self didRowTappedAtFirstTime:self.isAlreadyTapped];
        }
    } else {

        if (self.isAlreadyTapped == YES) {

            self.isAlreadyTapped = NO;
            [self cellIsTappedAtSecondTime];
        } else {

            self.isAlreadyTapped = YES;
            [self didRowTappedAtFirstTime:self.isAlreadyTapped];
        }
    }
}

#pragma mark - Fb call configuration
/**************************************************************************************************
 Function to handle Facebook cell configuration
 **************************************************************************************************/

- (void)facebookCellConfiguration:(BOOL)isDisplay {

        //  NSLog(@"%hhd", isDisplay);

    if (isDisplay == YES) {

        [imgVwOfComentFb setHidden:NO];
        [imgVwSeperatorLine setHidden:NO];
        [imgVwOfLikeFb setHidden:NO];
        [lblCommentFb setHidden:NO];
        [lblLike setHidden:NO];
        [lblFbLikeCount setHidden:NO];
        [btnMoreFb setHidden:NO];

        [self setGradientColorOfFB];
        imgVwSeperatorLine.backgroundColor = [UIColor lightGrayColor];
        lblText.textColor = [UIColor whiteColor];
        lblName.textColor = [UIColor whiteColor];
        btnMoreTweet.titleLabel.textColor = [UIColor whiteColor];
        lblTime.textColor = [UIColor whiteColor];
        lblSocialType.textColor = [UIColor whiteColor];
    } else {

        [imgVwOfComentFb setHidden:YES];
        [imgVwSeperatorLine setHidden:NO];
        [imgVwOfLikeFb setHidden:YES];
        [lblCommentFb setHidden:YES];
        [lblLike setHidden:YES];
        [lblFbLikeCount setHidden:YES];
        [imgVwBgColor setHidden:YES];
        imgVwSeperatorLine.backgroundColor = [UIColor lightGrayColor];

        [btnMoreFb setHidden:YES];

        self.contentView.backgroundColor =  [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblName.textColor = [UIColor blackColor];
        lblTime.textColor = [UIColor darkGrayColor];
        lblSocialType.textColor = [UIColor blackColor];
    }
}

#pragma mark - FB cell gradient
/**************************************************************************************************
 Function to set fb cell gradient
 **************************************************************************************************/

- (void)setGradientColorOfFB {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = imgVwBgColor.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:59/255.0f green:90/256.0f blue:153/256.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:66/255.0f green:99/255.0f blue:159/255.0f alpha:1.0]CGColor] ,(id)[[UIColor colorWithRed:75/255.0f green:114/255.0f blue:195/255.0f alpha:1.0] CGColor], (id)[[UIColor colorWithRed:79/255.0f green:120/255.0f blue:204/255.0f alpha:1.0] CGColor], nil];
    [imgVwBgColor.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Twitter call configuration
/**************************************************************************************************
 Function to handle twitter cell configuration
 **************************************************************************************************/

- (void)twitterCellConfiguration:(BOOL)isDisplay  {

    if (isDisplay == YES) {

        [btnReply setHidden:NO];
        [btnRetweet setHidden:NO];
        [btnFavourate setHidden:NO];
        [lblTweet setHidden:NO];
        [btnMoreTweet setHidden:NO];
        [lblFavourate setHidden:NO];
        [imgVwSeperatorLine setHidden:NO];
        imgVwSeperatorLine.backgroundColor = [UIColor lightGrayColor];

        lblText.textColor = [UIColor whiteColor];
        lblName.textColor = [UIColor whiteColor];
        lblTime.textColor = [UIColor whiteColor];
        lblSocialType.textColor = [UIColor whiteColor];

        [self setGradientColorOfTwitter];
    } else {

        [btnReply setHidden:YES];
        [btnMoreTweet setHidden:YES];
        [btnRetweet setHidden:YES];
        [btnFavourate setHidden:YES];
        [lblTweet setHidden:YES];
        [lblFavourate setHidden:YES];
        [imgVwBgColor setHidden:YES];
        [imgVwSeperatorLine setHidden:NO];
        imgVwSeperatorLine.backgroundColor = [UIColor lightGrayColor];

        self.contentView.backgroundColor =  [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblName.textColor = [UIColor blackColor];
        lblTime.textColor = [UIColor darkGrayColor];
        lblSocialType.textColor = [UIColor blackColor];
    }
}

#pragma mark - Twitter cell gradient
/**************************************************************************************************
 Function to set twitter cell gradient
 **************************************************************************************************/

- (void)setGradientColorOfTwitter {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = imgVwBgColor.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:70/255.0f green:144/256.0f blue:241/256.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:74/255.0f green:146/255.0f blue:244/255.0f alpha:1.0] CGColor], (id)[[UIColor colorWithRed:75/255.0f green:160/255.0f blue:245/255.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:80/255.0f green:172/255.0f blue:247/255.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:87/255.0f green:179/255.0f blue:249/255.0f alpha:1.0] CGColor], nil];
    [imgVwBgColor.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Instagram call configuration
/**************************************************************************************************
 Function to handle instagram cell configuration
 **************************************************************************************************/

- (void)instagramCellConfiguration:(BOOL)isDisplay  {

    if (isDisplay == YES) {

        [imgVwOfComentFb setHidden:NO];
        [imgVwOfLikeInstagram setHidden:NO];
        [lblCommentFb setHidden:NO];
        [lblLike setHidden:NO];
        [lblInstCommentCount setHidden:NO];
        [lblInstLikeCount setHidden:NO];
        [imgVwSeperatorLine setHidden:NO];
        imgVwSeperatorLine.backgroundColor = [UIColor lightGrayColor];

        lblText.textColor = [UIColor whiteColor];
        lblName.textColor = [UIColor whiteColor];
        lblTime.textColor = [UIColor whiteColor];
        lblSocialType.textColor = [UIColor whiteColor];

        [self setGradientColorOfInstagram];
    } else {

        [imgVwOfComentFb setHidden:YES];
        [imgVwOfLikeInstagram setHidden:YES];
        [lblCommentFb setHidden:YES];
        [lblLike setHidden:YES];
        [lblInstCommentCount setHidden:YES];
        [lblInstLikeCount setHidden:YES];
        [imgVwSeperatorLine setHidden:NO];
        imgVwSeperatorLine.backgroundColor = [UIColor lightGrayColor];


        self.contentView.backgroundColor =  [UIColor whiteColor];
        lblText.textColor = [UIColor darkGrayColor];
        lblName.textColor = [UIColor blackColor];
        lblTime.textColor = [UIColor darkGrayColor];
        lblSocialType.textColor = [UIColor blackColor];
    }
}

#pragma mark - Instagram cell gradient
/**************************************************************************************************
 Function to set instagram cell gradient
 **************************************************************************************************/

- (void)setGradientColorOfInstagram {

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = imgVwBgColor.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:56/255.0f green:94/256.0f blue:135/256.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:61/255.0f green:124/255.0f blue:177/255.0f alpha:1.0] CGColor],(id)[[UIColor colorWithRed:61/255.0f green:125/255.0f blue:178/255.0f alpha:1.0]CGColor], nil];
    [imgVwBgColor.layer insertSublayer:gradient atIndex:0];
}

#pragma mark - Hide and show labels (time, name, title)

- (void)isPaggingForMoreFeeds:(BOOL)isPagging {

    imgVwOfUserProfile.hidden = isPagging;
    lblSocialType.hidden = isPagging;
    lblText.hidden = isPagging;
    lblTime.hidden = isPagging;
    lblName.hidden = isPagging;
}

#pragma mark - Set values of feeds

- (void)setValueOfFeeds:(UserInfo*)objUserInfo {

    NSString *stringName = [objUserInfo.userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CGRect rectName = [stringName boundingRectWithSize:CGSizeMake([Constant widthOfCommentLblOfTimelineAndProfile], 21)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]}
                                       context:nil];

    lblName.text = objUserInfo.userName;
    lblName.frame = CGRectMake(63,lblName.frame.origin.y ,rectName.size.width, 21);
    btnName.frame = lblName.frame;

    lblTime.text =  [Constant  calculateTimesBetweenTwoDates:objUserInfo.time];


    NSString *string = [objUserInfo.strUserPost stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CGRect rect = [string boundingRectWithSize:CGSizeMake([Constant widthOfCommentLblOfTimelineAndProfile], 400)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:17.0]}
                                       context:nil];

    lblText.frame = CGRectMake(63, 52, [Constant widthOfCommentLblOfTimelineAndProfile], rect.size.height);
    lblText.text = string;

    lblSocialType.text = objUserInfo.userSocialType;

    lblInstLikeCount.text = [NSString stringWithFormat:@"%@", objUserInfo.instagramLikeCount];
    lblInstCommentCount.text = [NSString stringWithFormat:@"%@", objUserInfo.instagramCommentCount];

    lblTweet.text = objUserInfo.retweetCount;
    lblFavourate.text = objUserInfo.favourateCount;

    int heightWidthOfImg;
    if (IS_IPHONE_6_IOS8) {
        heightWidthOfImg = iPhone6_Width_Img;
    } else if (IS_IPHONE5) {
        heightWidthOfImg = iPhone5_Width_Img; //iPhone6_Width;
    } else {
        heightWidthOfImg = iPhone6_Plus_Width_Img;//iPhone6_Plus_Width;
    }
    if (imgVwPostImg.image != nil) {
        imgVwPostImg.image = nil;
        btnPlay.hidden = YES;
    }
    if (objUserInfo.postImg.length != 0) { //set post image

        imgVwPostImg.frame = CGRectMake(64, lblText.frame.size.height + lblText.frame.origin.y + 10, heightWidthOfImg,  heightWidthOfImg/2);
        imgVwPostImg.hidden = NO;
        imgVwPostImg.layer.cornerRadius = 5.0;
        imgVwPostImg.layer.masksToBounds = YES;

        imgVwSeperatorLine.frame = CGRectMake(60, rect.size.height + [Constant heightOfCellInTableVw] + 12, [Constant widthOfIPhoneView] - 60, 1.0);

        imgVwPostImg.backgroundColor = [UIColor clearColor];
        btnPlay.frame = imgVwPostImg.frame;

        [self setPostImage:objUserInfo];//user profile
        [self setFrameOfActivityView:imgVwPostImg.frame.size.height + imgVwPostImg.frame.origin.y + 10];//frames of activity
        imgVwBgColor.frame = CGRectMake(0, 0, [Constant widthOfIPhoneView], imgVwPostImg.frame.size.height + imgVwPostImg.frame.origin.y + 38);//image view frame that show gradient color

        btnPlay.hidden = NO;
        [btnPlay setImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
    } else {

        [self setFrameOfActivityView:lblText.frame.size.height + lblText.frame.origin.y+7];
        imgVwSeperatorLine.frame = CGRectMake(60, rect.size.height + 65 - 1, [Constant widthOfIPhoneView] - 60, 1.0);

        imgVwBgColor.frame = CGRectMake(0, 0, [Constant widthOfIPhoneView], lblText.frame.size.height + lblText.frame.origin.y + 38);
    }
}

- (void)setIconWhenActivityHasUsedByUser:(UserInfo *)objUserInfo {

    if (objUserInfo.fbLike == 1) {

        [imgVwOfLikeFb setImage:[UIImage imageNamed:@"Liked-active.png"]];
    } else {
        [imgVwOfLikeFb setImage:[UIImage imageNamed:@"Like_fb.png"]];
    }
    // [self getLikeCountOfFb];

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
}

#pragma mark - Set value in table view
/**************************************************************************************************
 Function to set values in feed list
 **************************************************************************************************/

- (void)setValueInSocialTableViewCustomCell:(UserInfo *)objUserInfo forRow:(NSInteger)row withSelectedCell:(NSMutableArray *)arrySelected withPagging:(BOOL)isPagging withOtherTimeline:(BOOL)isOtherTimeline withProfile:(BOOL)isProfile  {//withPreviousIndex:(NSInteger)index withType:(NSString *)type

    imgVwSeperatorLine.hidden = NO;
    if(isProfile == YES) {
        btnName.hidden = YES;
    }

    if (isPagging == YES) {
        spinner.hidden = NO;
        [spinner startAnimating];
        [self isPaggingForMoreFeeds:YES];
    } else {

        spinner.hidden = YES;
        [spinner stopAnimating];
        [self isPaggingForMoreFeeds:NO];

        if (self.userInfo != nil) {
            self.userInfo = nil; //assign value to user info object
        }
        self.userInfo = objUserInfo;

        self.isAlreadyTapped = NO;
        self.cellIndex = row; //set cell index

        [self setValueOfFeeds:objUserInfo]; //set values of feeds
        [self setColorOfFBTwitterInstHeading:objUserInfo withOtherTimeline:isOtherTimeline]; //set color on FB, Twitter, Inst heading

        [self setIconWhenActivityHasUsedByUser:objUserInfo]; //set activity icon


        BOOL iRowSelected = NO;
        if (arrySelected.count != 0) {
            for (NSString*iValue in arrySelected) {

                if ([iValue integerValue] == row) {
                    iRowSelected = YES;
                    break;
                } else {
                    iRowSelected = NO;
                }
            }
        }
        if (iRowSelected == YES) {  //BOOL isSelected = [[arrySelectedCell objectAtIndex:row]boolValue];

            imgVwSeperatorLine.frame = CGRectMake(60, imgVwBgColor.frame.size.height + imgVwBgColor.frame.origin.y, [Constant widthOfIPhoneView] - 60, 1.0);

            self.isAlreadyTapped = YES;
            imgVwBgColor.hidden = NO;
            [self sendSubviewToBack:imgVwBgColor];

            if ([objUserInfo.userSocialType isEqualToString: @"Facebook"]) {
                [self facebookCellConfiguration:YES];
            } else if ([objUserInfo.userSocialType isEqualToString: @"Twitter"]) {
                [self twitterCellConfiguration:YES];
            } else {
                [self instagramCellConfiguration:YES];
            }
        } else {

            if (self.userInfo.postImg.length == 0) {
                    //imgVwSeperatorLine.frame = CGRectMake(60, lblText.frame.size.height + lblText.frame.origin.y+13, [Constant widthOfIPhoneView] - 60, 1.0);
            } else {
                    // imgVwSeperatorLine.frame = CGRectMake(60,  rect.size.height + [Constant heightOfCellInTableVw] + 12, [Constant widthOfIPhoneView] - 60, 1.0);
            }
            self.isAlreadyTapped = NO;
            imgVwBgColor.hidden = YES;
        }


        if ([objUserInfo.type isEqualToString:@"video"]) {
            [btnPlay setImage:[UIImage imageNamed:@"play-btn.png"] forState:UIControlStateNormal];
             [self.contentView bringSubviewToFront:btnPlay];
        }
    }
}

#pragma mark - Set color of Social type
/**************************************************************************************************
 Function to set color of social timeline
 **************************************************************************************************/

- (void)setColorOfFBTwitterInstHeading:(UserInfo *)objUserInfo withOtherTimeline:(BOOL)isOtherTimeline {

    if ([objUserInfo.userSocialType isEqualToString: @"Facebook"]) {

        if (isOtherTimeline == NO) {
            lblSocialType.textColor = [UIColor colorWithRed:92/256.0f green:103/256.0f blue:159/256.0f alpha:1.0];
        } else {
            lblSocialType.textColor = [UIColor lightGrayColor];
        }
        [self profileImgOfFbUser:objUserInfo]; //upload profile image

    } else if ([objUserInfo.userSocialType isEqualToString: @"Twitter"]) {

        if (isOtherTimeline == NO) {
            lblSocialType.textColor = [UIColor colorWithRed:87/256.0f green:171/256.0f blue:218/256.0f alpha:1.0];
        } else {
            lblSocialType.textColor = [UIColor lightGrayColor];
        }
        [self setProfileImageOfTwitterAndInstagram:objUserInfo];
    } else {

        if (isOtherTimeline == NO) {
            lblSocialType.textColor = [UIColor colorWithRed:93/256.0f green:122/256.0f blue:154/256.0f alpha:1.0];
        } else {
            lblSocialType.textColor = [UIColor lightGrayColor];
        }
        [self setProfileImageOfTwitterAndInstagram:objUserInfo];
    }
}

#pragma mark - Set frame of like, favourate, comment, retweet and reply
/**************************************************************************************************
 Function to set frame of like, favourate, comment, retweet and reply butotn
 **************************************************************************************************/

- (void)setFrameOfActivityView:(NSInteger)yAxis {

    int appendXAxis;
    int extraGap;
    int tweetGap;

    if (IS_IPHONE5){
        appendXAxis = 0;
        extraGap = 0;
        tweetGap = 0;
    } else  if (IS_IPHONE_6_IOS8) {
        appendXAxis = 20;
        extraGap = 20;
        tweetGap = 0;
    } else {
        appendXAxis = 40;
        extraGap = 35;
        tweetGap = 5;
    }

    [imgVwOfComentFb setFrame:CGRectMake(imgVwOfComentFb.frame.origin.x+appendXAxis+extraGap, yAxis, 20, 20)];
    [imgVwOfLikeFb setFrame:CGRectMake(imgVwOfLikeFb.frame.origin.x+appendXAxis, yAxis, 20, 20)];
    [lblCommentFb setFrame:CGRectMake(lblCommentFb.frame.origin.x+appendXAxis+extraGap, yAxis, 80, 20)];
    [lblLike setFrame:CGRectMake(lblLike.frame.origin.x+appendXAxis , yAxis, 70, 20)];
    [lblFbLikeCount setFrame:CGRectMake(lblFbLikeCount.frame.origin.x+appendXAxis, yAxis, 70, 20)];
    [btnMoreFb setFrame:CGRectMake(btnMoreFb.frame.origin.x, yAxis, btnMoreFb.frame.size.width, btnMoreFb.frame.size.height)];

    [btnFavourate setFrame:CGRectMake(btnFavourate.frame.origin.x+appendXAxis+extraGap, yAxis-2, btnFavourate.frame.size.width, btnFavourate.frame.size.height)];
    [btnReply setFrame:CGRectMake(btnReply.frame.origin.x+appendXAxis, yAxis-2, btnReply.frame.size.width, btnReply.frame.size.height)];
    [btnRetweet setFrame:CGRectMake(btnRetweet.frame.origin.x+appendXAxis-extraGap, yAxis+1, btnRetweet.frame.size.width, btnRetweet.frame.size.height)];
    [btnMoreTweet setFrame:CGRectMake(btnMoreTweet.frame.origin.x+appendXAxis, yAxis-2, btnMoreTweet.frame.size.width, btnMoreTweet.frame.size.height)];

    [lblFavourate setFrame:CGRectMake(lblFavourate.frame.origin.x+appendXAxis+extraGap, yAxis, 70, lblFavourate.frame.size.height)];
    [lblTweet setFrame:CGRectMake(lblTweet.frame.origin.x + tweetGap, yAxis, 70, lblTweet.frame.size.height)];

    [imgVwOfLikeInstagram setFrame:CGRectMake(imgVwOfLikeInstagram.frame.origin.x+appendXAxis, yAxis, 20, 20)];
    [lblInstCommentCount setFrame:CGRectMake(lblInstCommentCount.frame.origin.x+appendXAxis+extraGap, yAxis, lblInstCommentCount.frame.size.width, 20)];
    [lblInstLikeCount setFrame:CGRectMake(lblInstLikeCount.frame.origin.x+appendXAxis, yAxis, lblInstLikeCount.frame.size.width, 20)];
}

#pragma mark - Set profile image of twitter and Instagram
/**************************************************************************************************
 Function to set profile image of twitter and Instagram
 **************************************************************************************************/

- (void)setProfileImageOfTwitterAndInstagram:(UserInfo *)objUserInfo {

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

#pragma mark - Set post image
/**************************************************************************************************
 Function to set post image
 **************************************************************************************************/

- (void)setPostImage:(UserInfo *)objUserInfo {

    //  imgVwPostImg.imageURL = [NSURL URLWithString:objUserInfo.postImg];

    [imgVwPostImg sd_setImageWithURL:[NSURL URLWithString:objUserInfo.postImg] placeholderImage:nil];
}

#pragma mark - Set User profile images
/**************************************************************************************************
 Function to set profile image of facebook
 **************************************************************************************************/

- (void)profileImgOfFbUser:(UserInfo *)objUserInfo {

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

#pragma mark - Like of Fb POst
/**************************************************************************************************
 Function to get like of fb post
 **************************************************************************************************/

/*- (void)getLikeCountOfFb {

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
}*/

@end

//
//  CustomTableCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "AsyncImageView.h"

@protocol CustomTableCellDelegate <NSObject>

- (void)didSelectRowWithObject:(UserInfo *)objuserInfo withFBProfileImg:(NSString *)imgName;
- (void)tappedOnCellToShowActivity:(UserInfo *)objuserInfo withCellIndex:(NSInteger)cellIndex withSelectedPrNot:(BOOL)isSelected;
- (void)userProfileBtnTapped:(UserInfo*)userInfo;

@end

@interface CustomTableCell : UITableViewCell {

    IBOutlet UIImageView *imgVwBgColor;

    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblSocialType;
    IBOutlet UILabel *lblText;
    IBOutlet UILabel *lblTime;
    IBOutlet UIImageView *imgVwOfUserProfile;
    IBOutlet AsyncImageView *imgVwPostImg;
    IBOutlet UIButton *btnPlay;

    IBOutlet UIImageView *imgVwOfLikeFb;
    IBOutlet UIImageView *imgVwOfComentFb;
    IBOutlet UILabel *lblCommentFb;
    IBOutlet UILabel *lblLike;
    IBOutlet UILabel *lblFbLikeCount;

    IBOutlet UIButton *btnReply;
    IBOutlet UIButton *btnRetweet;
    IBOutlet UIButton *btnFavourate;
    IBOutlet UIButton *btnMoreTweet;
    IBOutlet UILabel *lblTweet;
    IBOutlet UILabel *lblFavourate;
    IBOutlet UIButton *btnProfile;
    IBOutlet UIButton *btnMoreFb;

    IBOutlet UIImageView *imgVwOfLikeInstagram;
    UIActivityIndicatorView *spinner;
        //IBOutlet UITextView *txtVwMessage;
}

@property (nonatomic, strong) NSNumber *touchCount;
@property (nonatomic, strong) NSString *strProfileImg;
@property (unsafe_unretained)id <CustomTableCellDelegate> customCellDelegate;
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic)NSInteger cellIndex;

- (void)cellTouchCountIncrement;
- (void)cellTouchCountDecrement;
- (void)setValueInSocialTableViewCustomCell:(UserInfo *)objUserInfo forRow:(NSInteger)row withSelectedIndexArray:(NSMutableArray*)arrayOfSelectedIndex withSelectedCell:(NSMutableArray *)arrySelectedCell withPagging:(BOOL)isPagging;

@end

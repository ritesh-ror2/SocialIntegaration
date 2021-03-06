//
//  ProfileTableViewCustomCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserComment.h"
#import "AsyncImageView.h"

@protocol MessageCellTappedDelegate <NSObject>

- (void)showAllMessage:(NSInteger)cellIndex;

@end

@interface MessageCustomCell : UITableViewCell {

    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblSocialType;
    IBOutlet UILabel *lblText;
    IBOutlet UILabel *lblTime;
    IBOutlet UIImageView *imgVwOfUserProfile;
    IBOutlet AsyncImageView *imgVwPostImg;
    IBOutlet UIButton *btnPlay;
    IBOutlet UITextView *txtVwMessage;
}

@property (unsafe_unretained)id <MessageCellTappedDelegate> delegate;

- (void)setMessageInTableViewCustomCell:(UserComment*)objUserComment withRowIndex:(NSInteger)rowIndex;

@end

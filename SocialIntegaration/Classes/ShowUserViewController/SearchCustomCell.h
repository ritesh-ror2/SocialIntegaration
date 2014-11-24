//
//  SearchCustomCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@protocol SearchCustomDelegate <NSObject>

- (void)followOrNotFollow:(UserInfo *)userInfo withTitle:(NSString *)follow;
- (void)userProfileBtnTapped:(UserInfo *)userInfo;

@end

@interface SearchCustomCell : UITableViewCell {

    IBOutlet UILabel *lblResult;
    IBOutlet UILabel *lblDescription;
    IBOutlet UIButton *btnFollow;
    IBOutlet UIImageView *imgVwUser;
    IBOutlet UITextView *txtVwDescription;
    IBOutlet UIButton *btnImage;
}

@property (nonatomic, strong) id <SearchCustomDelegate>delegate;
@property (nonatomic, strong) UserInfo *userInfo;

- (void)setSearchResultIntableView:(UserInfo *)userInfo;
- (IBAction)followBtnTapped:(id)sender;

@end

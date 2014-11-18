
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


@interface CommentCustomCell : UITableViewCell {

    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblText;
    IBOutlet UILabel *lblTime;
    IBOutlet UIImageView *imgVwOfUserProfile;
}

- (void)setCommentInTableView:(UserComment *)objUseroCmment;

@end

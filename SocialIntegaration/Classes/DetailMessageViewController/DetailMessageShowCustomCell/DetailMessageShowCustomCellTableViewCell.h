//
//  DetailMessageShowCustomCellTableViewCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserComment.h"

@interface DetailMessageShowCustomCellTableViewCell : UITableViewCell {

    UILabel *lblMessage;
    UIImageView *imgVwUser;
    UIImageView *imgVwArrow;

    UIImageView *imgVwBackground;
}

- (void)setDetailMessageOnTableView:(UserComment*)objComment withUserId:(NSString*)userId;

@end

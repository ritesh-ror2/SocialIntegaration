//
//  CustomGiveCommentCell.m
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "CustomGiveCommentCell.h"
#import "CommentViewController.h"
#import "Constant.h"

@implementation CustomGiveCommentCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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

- (void)setUserNameToGiveComment:(NSString *)userName {

    if (txtVwComment.text.length == 0) {
        [Constant showAlert:@"Error" forMessage:@"Please enter message"];
    }
    lblName.text = userName;
    [btnPost addTarget:self action:@selector(postBtnTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)postBtnTapped {

    if ([self.delegate respondsToSelector:@selector(postFBComment:)]) {
        [self.delegate postFBComment:txtVwComment.text];
    }
}

@end

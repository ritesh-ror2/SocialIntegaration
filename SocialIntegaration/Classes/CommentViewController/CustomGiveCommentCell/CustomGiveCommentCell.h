//
//  CustomGiveCommentCell.h
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CustomGiveCommentDelegate <NSObject>

- (void)postFBComment:(NSString *)comment;

@end

@interface CustomGiveCommentCell : UITableViewCell {

    IBOutlet UILabel *lblName;
    IBOutlet UITextView *txtVwComment;
    IBOutlet UIButton *btnPost;
}

@property (unsafe_unretained) id <CustomGiveCommentDelegate>delegate;

@end

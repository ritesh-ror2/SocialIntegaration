//
//  ScrollVwOfComment.m
//  SocialIntegaration
//
//  Created by GrepRuby on 02/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "ScrollVwOfComment.h"

@implementation ScrollVwOfComment

@synthesize parentVw;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self.parentVw respondsToSelector:@selector(touchesBegan:withEvent:)]) {
        [self.parentVw touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self.parentVw respondsToSelector:@selector(touchesMoved:withEvent:)]) {
        [self.parentVw touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self.parentVw respondsToSelector:@selector(touchesEnded:withEvent:)]) {
        [self.parentVw touchesEnded:touches withEvent:event];
    }
}

@end

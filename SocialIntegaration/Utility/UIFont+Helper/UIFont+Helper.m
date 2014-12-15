//
//  UIFont+Helper.m
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "UIFont+Helper.h"

@implementation UIFont (Helper)

#pragma mark - Set font name with style

+ (UIFont *)fontWithRegularWithSize:(CGFloat)fontSize {

     return [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
}


+ (UIFont *)fontWithMediumWithSize:(CGFloat)fontSize {

    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize];
}

+ (UIFont *)fontWithLightWithSize:(CGFloat)fontSize {

    return [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
}

@end

//
//  PushSegueWithOutAnimation.m
//  SocialIntegaration
//
//  Created by GrepRuby on 02/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "PushSegueWithOutAnimation.h"

@implementation PushSegueWithOutAnimation

#pragma mark - Push view without animation

-(void) perform {

    [[[self sourceViewController] navigationController] pushViewController:[self  destinationViewController] animated:NO];
}

@end

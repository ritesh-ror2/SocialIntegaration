//
//  Constant.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject 

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (void)showAlert:(NSString *)title forMessage:(NSString *)message;

+ (NSString *)convertDateOFFB:(NSString*)strdate;
+ (NSString *)convertDateOFTwitter:(NSString*)strdate;
+ (NSString *)convertDateOFInstagram:(NSDate*)date;

+ (NSString *)calculateTimesBetweenTwoDates:(NSString *)strGivenDate;

+ (int)heightOfCellInTableVw;
+ (int)widthOfCommentLblOfTimelineAndProfile;

+ (void)showNetworkIndicator;
+ (void)hideNetworkIndicator;
+ (NSString *)convertDateOfTwitterInDatabaseFormate:(NSString *)createdDate;

@end

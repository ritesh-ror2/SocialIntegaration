//
//  NSDate+Helper.h
//  Babiinet
//
//  Created by FxByte on 18/07/14.
//  Copyright (c) 2014 FxByte. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

+ (NSDate *)dateFromString:(NSString *)strPreviousDate;
+ (NSDate *)dateFromCustomFormate:(NSString *)strPreviousDate;

@end

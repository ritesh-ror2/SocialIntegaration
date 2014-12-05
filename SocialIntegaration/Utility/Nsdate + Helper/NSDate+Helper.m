//
//  NSDate+Helper.m
//  Babiinet
//
//  Created by FxByte on 18/07/14.
//  Copyright (c) 2014 FxByte. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

#pragma mark - Date from string

+ (NSDate *)dateFromString:(NSString *)strPreviousDate {
    
    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formate dateFromString:strPreviousDate];
    return date;
}

+ (NSDate *)dateFromCustomFormate:(NSString *)strPreviousDate {
    
    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"yyyy MMM dd"];
    NSDate *date = [formate dateFromString:strPreviousDate];
    return date;
}

+ (NSDate *)dateFromStringInUserNotify:(NSString *)strPreviousDate {

    NSDateFormatter *formate = [[NSDateFormatter alloc]init];
    [formate setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formate dateFromString:strPreviousDate];
    return date;
}

@end

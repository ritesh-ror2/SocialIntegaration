//
//  Constant.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "Constant.h"
#import "NSDate+Helper.h"

#define DATE_COMPONENTS (NSDayCalendarUnit|NSMinuteCalendarUnit| NSHourCalendarUnit | NSDayCalendarUnit| NSWeekOfMonthCalendarUnit|NSWeekOfYearCalendarUnit)

@implementation Constant

#pragma mark - Methof to mask image

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {

    CGImageRef imageReference = image.CGImage;
	CGImageRef maskReference = maskImage.CGImage;

	CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL, // Decode is null
                                             YES
                                             );

	CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
	CGImageRelease(imageMask);

	UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
	CGImageRelease(maskedReference);

	return maskedImage;
}

#pragma mark - Show alert view

+ (void)showAlert:(NSString *)title forMessage:(NSString *)message {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Calculate time between two dates

+ (NSString *)calculateTimesBetweenTwoDates:(NSString *)strGivenDate {

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *toDate = [NSDate dateFromString:strDate];

    NSDate *fromDate = [NSDate dateFromString:strGivenDate];

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:DATE_COMPONENTS
                                                        fromDate:fromDate toDate:toDate options:0];
    long diffInDate = components.minute;
    NSString *strDiff;

    if (components.hour == 0) {

        strDiff = [NSString stringWithFormat:@"%ld m", diffInDate];
    } else if (components.day == 0) {

        diffInDate = components.hour;
        strDiff = [NSString stringWithFormat:@"%ld h", diffInDate];
    } else if (components.day != 0) {

        diffInDate = components.day;
        strDiff = [NSString stringWithFormat:@"%ld d", diffInDate];
    } else if (components.day != 0) {

        diffInDate = components.month;
        strDiff = [NSString stringWithFormat:@"%ld m", diffInDate];
    } else if (components.day != 0) {

        diffInDate = components.year;
        strDiff = [NSString stringWithFormat:@"%ld y", diffInDate];
    }
    return strDiff;
}

#pragma mark - Convert date of FB

+ (NSString *)convertDateOFFB:(NSString*)strdate {

    NSString *strConvertDate = [strdate substringWithRange:NSMakeRange(0, strdate.length-5)]; //remove 0000 from date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *dateGMT = [dateFormatter dateFromString:strConvertDate];

    //second from gmt
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [dateGMT dateByAddingTimeInterval:timeZoneSeconds];

    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strConvertedDate = [dateFormatter stringFromDate:dateInLocalTimezone];
    NSLog(@"%@", strConvertedDate);
    return strConvertedDate;
}

+ (NSString *)convertDateOFInstagram:(NSDate*)date {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
        //second from gmt
        // NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
        // NSDate *dateInLocalTimezone = [date dateByAddingTimeInterval:timeZoneSeconds];

    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strConvertedDate = [dateFormatter stringFromDate:date];
    NSLog(@"%@", strConvertedDate);
    return strConvertedDate;
}

#pragma mark - Convert date of twitter

+ (NSString *)convertDateOFTweeter:(NSString*)strdate {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TWEETERDATEFORMATE];
    NSDate *dateGMT = [dateFormatter dateFromString:strdate];

    //second from gmt
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [dateGMT dateByAddingTimeInterval:timeZoneSeconds];

    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strConvertedDate = [dateFormatter stringFromDate:dateInLocalTimezone];
    NSLog(@"%@", strConvertedDate);
    return strConvertedDate;
}

@end

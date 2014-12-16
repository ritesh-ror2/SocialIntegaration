//
//  Constant.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "Constant.h"
#import "NSDate+Helper.h"

#define DATE_COMPONENTS (NSMinuteCalendarUnit| NSHourCalendarUnit | NSDayCalendarUnit| NSMonthCalendarUnit|NSYearCalendarUnit)

@implementation Constant

#pragma mark - Methof to mask image

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {

  /*  CGImageRef imageReference = image.CGImage;
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
	return maskedImage;*/

    CGImageRef imgRef  = [image CGImage];
    CGImageRef maskRef = [maskImage CGImage];


    int maskWidth      = (int) CGImageGetWidth(maskRef);
    int maskHeight     = (int) CGImageGetHeight(maskRef);
        //  round bytesPerRow to the nearest 16 bytes, for performance's sake
    int bytesPerRow    = (maskWidth + 15) & 0xfffffff0;
    int bufferSize     = bytesPerRow * maskHeight;

        //  allocate memory for the bits
    CFMutableDataRef dataBuffer = CFDataCreateMutable(kCFAllocatorDefault, 0);
    CFDataSetLength(dataBuffer, bufferSize);

        //  the data will be 8 bits per pixel, no alpha
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx            = CGBitmapContextCreate(CFDataGetMutableBytePtr(dataBuffer),
                                                        maskWidth, maskHeight,
                                                        8, bytesPerRow, colourSpace, kCGImageAlphaNone);
        //  drawing into this context will draw into the dataBuffer.
    CGContextDrawImage(ctx, CGRectMake(0, 0, maskWidth, maskHeight), maskRef);
    CGContextRelease(ctx);

        //  now make a mask from the data.
    CGDataProviderRef dataProvider  = CGDataProviderCreateWithCFData(dataBuffer);
    CGImageRef mask                 = CGImageMaskCreate(maskWidth, maskHeight, 8, 8, bytesPerRow,
                                                        dataProvider, NULL, FALSE);

    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colourSpace);
    CFRelease(dataBuffer);

    CGImageRef masked = CGImageCreateWithMask(imgRef, mask);
    UIImage *imgMasked = [UIImage imageWithCGImage:masked];
    CFRelease(mask);
    return imgMasked;
}

#pragma mark - Show alert view

+ (void)showAlert:(NSString *)title forMessage:(NSString *)message {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles: nil];
    [alert show];
}

#pragma mark - Calculate time between two dates
/**************************************************************************************************
 Function to calculate time between two dates
 **************************************************************************************************/

+ (NSString *)calculateTimesBetweenTwoDates:(NSString *)strGivenDate {

    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:DatabaseDateFormate];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *toDate = [NSDate dateFromString:strDate];

    NSDate *fromDate = [NSDate dateFromString:strGivenDate];
    NSLog(@"%@  from %@", toDate, fromDate);

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:DATE_COMPONENTS
                                                        fromDate:fromDate toDate:toDate options:0];
    long diffInDate = components.minute;

    NSString *strDiff;
    NSLog(@"%li", (long)components.month);
    if (components.hour == 0 && components.day == 0) {

        strDiff = [NSString stringWithFormat:@"%ldm", diffInDate];
    } else if (components.day == 0) {

        diffInDate = components.hour;
        strDiff = [NSString stringWithFormat:@"%ldh", diffInDate];
    } else if (components.day != 0 && components.month == 0) {

        diffInDate = components.day;
        strDiff = [NSString stringWithFormat:@"%ldd", diffInDate];
    } else if (components.month != 0 && components.year != 0) {

        diffInDate = components.month;
        strDiff = [NSString stringWithFormat:@"%ldm", diffInDate];
    } else if (components.year != 0) {

        diffInDate = components.year;
        strDiff = [NSString stringWithFormat:@"%ldy", diffInDate];
    }
    return strDiff;
}

#pragma mark - Convert date of FB
/**************************************************************************************************
 Function to convert date formate of fb
 **************************************************************************************************/

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

#pragma mark - Convert date of twitter
/**************************************************************************************************
 Function to convert date formate of twitter
 **************************************************************************************************/

+ (NSString *)convertDateOfTwitterInDatabaseFormate:(NSString *)createdDate {

    NSString *strDateInDatabaseFormate;

    NSString *strYear = [createdDate substringWithRange:NSMakeRange(createdDate.length-4, 4)];
    NSString *strMonth = [createdDate substringWithRange:NSMakeRange(4, 3)];
    NSString *strDate = [createdDate substringWithRange:NSMakeRange(8, 2)];

    NSString *strTime = [createdDate substringWithRange:NSMakeRange(11, 8)];//14

    NSString *finalDate = [NSString stringWithFormat:@"%@ %@ %@", strDate, strMonth, strYear];

    strDateInDatabaseFormate = [NSString stringWithFormat:@"%@ %@", finalDate, strTime];

    return strDateInDatabaseFormate;
}

#pragma mark - Convert date formate from instagram
/**************************************************************************************************
 Function to convert date formate of instagram
 **************************************************************************************************/

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
/**************************************************************************************************
 Function to convert date formate of twitter
 **************************************************************************************************/

+ (NSString *)convertDateOFTwitter:(NSString*)strdate {

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

#pragma mark - Hide and show network indicator
/**************************************************************************************************
 Function to  hide and show network activity indicator
 **************************************************************************************************/

+ (void)showNetworkIndicator {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
}

+ (void)hideNetworkIndicator {

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
}

+ (int)heightOfCellInTableVw {

    int heightCell;

    if (IS_IPHONE_6P_IOS8) {
        heightCell = (iPhone6_Plus_Width_Img/2) + 65;
    } else if (IS_IPHONE_6_IOS8) {
        heightCell = (iPhone6_Width_Img/2) + 65;
    } else {
        heightCell = (iPhone5_Width_Img/2) + 65;
    }
    return heightCell;
}

+ (int)withOfImageInDescriptionView {

    int height;

    if (IS_IPHONE_6P_IOS8) {
        height = iPhone6_Plus_Width_Img;
    } else if (IS_IPHONE_6_IOS8) {
        height = iPhone6_Width_Img;
    } else {
        height = iPhone5_Width_Img;
    }
    return height;
}

+ (int)heightOfImageInDescriptiveVw {

    int height;

    if (IS_IPHONE_6P_IOS8) {
        height = iPhone6_Plus_Width_Img + 65;
    } else if (IS_IPHONE_6_IOS8) {
        height = iPhone6_Width_Img + 65;
    } else {
        height = iPhone5_Width_Img + 65;
    }
    return height;
}

+ (int)widthOfIPhoneView {

    int width;

    if (IS_IPHONE_6P_IOS8) {
        width = iPhone6_Plus_Width;
    } else if (IS_IPHONE_6_IOS8) {
        width = iPhone6_Width;
    } else {
        width = iPhone5_Width;
    }
    return width;
}

+ (int)widthOfCommentLblOfTimelineAndProfile {

    int widthOfcommentLbl;

    if (IS_IPHONE5) {
        widthOfcommentLbl = iPhone5_lbl_width;
    } else if (IS_IPHONE_6_IOS8) {
        widthOfcommentLbl = iPhone6_lbl_width;
    } else {
        widthOfcommentLbl = iPhone6_Plus_lbl_width;
    }

//    if (IS_IPHONE_6P_IOS8) {
//        widthOfcommentLbl = iPhone6_lbl_width;
//    } else if (IS_IPHONE5) {
//        widthOfcommentLbl = iPhone5_lbl_width;
//    }

    return widthOfcommentLbl;
}

@end

//
//  UserInfo.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, strong) NSString *strUserImg;
@property (nonatomic, strong) NSString *strPostImg;
@property (nonatomic, strong) NSString *strUserName;
@property (nonatomic, strong) NSString *strUserSocialType;
@property (nonatomic, strong) NSString *strUserPost;
@property (nonatomic, strong) NSString *struserTime;
@property (nonatomic, strong) NSString *fromId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *objectIdFB;
@property (nonatomic, strong) NSString *statusId;
@property (nonatomic, strong) NSString *retweetCount;
@property (nonatomic, strong) NSString *retweeted;
@property (nonatomic, strong) NSString *favourateCount;
@property (nonatomic, strong) NSString *favourated;
@property (nonatomic, strong) NSString *videoUrl;

@end

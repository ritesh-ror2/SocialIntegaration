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
@property (nonatomic, strong) NSString *largeImageUrl;
@property (nonatomic) BOOL fbLike;
@property (nonatomic) BOOL isFollowing;
@property (nonatomic, strong) NSDictionary *dicOthertUser;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *postId;

@property (nonatomic, strong) NSString *mediaIdOfInstagram;
@property (nonatomic, strong) NSString *instagramLikeCount;
@property (nonatomic, strong) NSString *instagramCommentCount;

@end

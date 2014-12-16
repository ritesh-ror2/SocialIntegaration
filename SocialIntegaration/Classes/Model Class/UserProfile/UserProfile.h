//
//  UserProfile.h
//  SocialIntegaration
//
//  Created by GrepRuby on 10/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (nonatomic, strong) NSString *userImg;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *followers;
@property (nonatomic, strong) NSString *tweet;
@property (nonatomic, strong) NSString *post;
@property (nonatomic, strong) NSString *following;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *description;

@end

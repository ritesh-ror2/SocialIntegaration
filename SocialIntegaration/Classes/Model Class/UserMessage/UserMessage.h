//
//  UserMessage.h
//  SocialIntegaration
//
//  Created by GrepRuby on 19/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserMessage : NSObject

@property (nonatomic, strong) NSString *userImg;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *socialType;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *fromId;

@end

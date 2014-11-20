//
//  UserComment.h
//  SocialIntegaration
//
//  Created by GrepRuby on 17/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserComment : NSObject

@property (nonatomic, strong) NSString *userImg;
@property (nonatomic, strong) NSString *postImg;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userComment;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *fromId;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *socialType;

@end

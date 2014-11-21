//
//  UserNotification.h
//  SocialIntegaration
//
//  Created by GrepRuby on 21/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserNotification : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString * notif_id;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *notifType;
@property (nonatomic, strong) NSString *userImg;
@property (nonatomic, strong) NSString *fromId;

@end

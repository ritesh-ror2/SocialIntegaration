//
//  UserProfile+DatabaseHelper.h
//  SocialIntegaration
//
//  Created by GrepRuby on 14/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "UserProfile.h"
#import "Database.h"
#import <sqlite3.h>

@interface UserProfile (DatabaseHelper)

- (void)saveUserProfile;

- (void)updateProfileInfo:(NSString *)type;

+ (UserProfile*)getProfile:(NSString *)type;

+ (void)deleteProfile:(NSString *)type;

@end

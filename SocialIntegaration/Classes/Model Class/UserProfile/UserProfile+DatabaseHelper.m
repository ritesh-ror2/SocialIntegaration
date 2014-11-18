//
//  UserProfile+DatabaseHelper.m
//  SocialIntegaration
//
//  Created by GrepRuby on 14/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "UserProfile+DatabaseHelper.h"

@implementation UserProfile (DatabaseHelper)

#pragma mark - Save child info

- (void)saveUserProfile {

    sqlite3_stmt *insertStatement;
    const char *sqlQuery = "INSERT INTO userProfile (userId, name, imageUrl, followers, following, tweet, post, type) VALUES (?, ?, ?, ? , ?, ?, ?, ?)";
    if (sqlite3_prepare_v2(([[Database connection] getDatabase]), sqlQuery, -1, &(insertStatement), NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[Database connection] getDatabase]));
    }

        //binding values into query
    sqlite3_bind_text(insertStatement, 1, [self.userId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 2, [self.userName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 3, [self.userImg UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 4, [self.followers UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 5, [self.following UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 6, [self.tweet UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 7, [self.post UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insertStatement, 8, [self.type UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(insertStatement) != SQLITE_ERROR) {// executing query
        sqlite3_finalize(insertStatement); // finalizing tatement
    }
}
- (void)updateProfileInfo:(NSString *)type {

    sqlite3_stmt *updateStatement;
    NSString *querySearchData = [NSString stringWithFormat: @"UPDATE userProfile SET name = ?, imageUrl = ?  WHERE type = '%@'", type];

        // TODO: update child info
    const char *sql = [querySearchData UTF8String];

    if (sqlite3_prepare_v2([[Database connection] getDatabase], sql, -1, &updateStatement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[Database connection] getDatabase]));
    }

    sqlite3_bind_text(updateStatement, 1, [self.userId UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 2, [self.userName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 3, [self.userImg UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 4, [self.followers UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 5, [self.following UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 6, [self.tweet UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(updateStatement, 7, [self.post UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(updateStatement) != SQLITE_ERROR) {// executing query
        sqlite3_finalize(updateStatement); // finalizing tatement
    }
}

#pragma mark - Get child info

+ (UserProfile*)getProfile:(NSString *)type {

    sqlite3_stmt *selectStatement;
    UserProfile *objInfo;
    NSString *querySearchData = @"SELECT userId, name, imageUrl, followers, following, tweet, post FROM userProfile WHERE type = ?";

    const char *sql = [querySearchData UTF8String];

    if (sqlite3_prepare_v2([[Database connection] getDatabase], sql, -1, &selectStatement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[Database connection] getDatabase]));
    }

    sqlite3_bind_text(selectStatement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);

    while (sqlite3_step(selectStatement) == SQLITE_ROW) {

        objInfo = [[UserProfile alloc] init];

        char *userId = (char *)sqlite3_column_text(selectStatement, 0);
        objInfo.userId = [NSString stringWithUTF8String:(userId == nil ? "": userId)];

        char *name = (char *)sqlite3_column_text(selectStatement, 1);
        objInfo.userName = [NSString stringWithUTF8String:(name == nil ? "": name)];

        char *imgUrl = (char *)sqlite3_column_text(selectStatement, 2);
        objInfo.userImg = [NSString stringWithUTF8String:(imgUrl == nil ? "": imgUrl)];

        char *follower = (char *)sqlite3_column_text(selectStatement, 3);
        objInfo.followers = [NSString stringWithUTF8String:(follower == nil ? "": follower)];

        char *following = (char *)sqlite3_column_text(selectStatement, 4);
        objInfo.following = [NSString stringWithUTF8String:(following == nil ? "": following)];

        char *tweet = (char *)sqlite3_column_text(selectStatement, 5);
        objInfo.tweet = [NSString stringWithUTF8String:(tweet == nil ? "": tweet)];

        char *post = (char *)sqlite3_column_text(selectStatement, 6);
        objInfo.post  = [NSString stringWithUTF8String:(post == nil ? "": post)];
    }

    sqlite3_finalize(selectStatement);

    return objInfo;
}

#pragma mark - Delete child

+ (void)deleteProfile:(NSString *)type {

    sqlite3_stmt *deleteStatement;
    NSString *queryDelete = @"DELETE FROM userProfile WHERE type = ?";

    const char *sql = [queryDelete UTF8String];

    if (sqlite3_prepare_v2([[Database connection] getDatabase], sql, -1, &deleteStatement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([[Database connection] getDatabase]));
    }
    sqlite3_bind_text(deleteStatement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);//int(deleteStatement, 1, (int)childId);

    if (sqlite3_step(deleteStatement) == SQLITE_ROW) {

		NSLog(@"delet");
	}

    sqlite3_finalize(deleteStatement);
}

@end

//
//  Database.m
//  Babiinet
//
//  Created by FxByte on 21/08/14.
//  Copyright (c) 2014 FxByte. All rights reserved.
//

#import "Database.h"

@implementation Database

static sqlite3 *database = nil;

#pragma mark - Establish connection with database

+ (Database *)connection {
	
	static Database *con = nil;
	
	if (con == NULL) {
		
		//database connection
		con = [[Database alloc]init];
		NSError *error = [[NSError alloc]init];
		NSFileManager *filemanager = [NSFileManager defaultManager];
		
		NSArray *arryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
		NSString *basePath = [arryPath objectAtIndex:0];
		basePath = [basePath stringByAppendingPathComponent:@"Caches/Database"];
		[filemanager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
		NSString *strDocumentPath = [basePath stringByAppendingPathComponent:@"One.sqlite"];
		
		// check file is exist or not
		int success = [filemanager fileExistsAtPath:strDocumentPath];
		
		//if file not exist at path
		if (!success) {
			
			NSString *strDefaultPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"One.sqlite"];
			success = [filemanager copyItemAtPath:strDefaultPath toPath:strDocumentPath error:&error];
			if (!success) {
				NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
			}
            NSLog (@"paht -%@", strDefaultPath);
		}
		//file exist at path
		if (success) {
			
            if (sqlite3_open([strDocumentPath UTF8String], &database) == SQLITE_OK) {
                
            } else {
                sqlite3_close(database);
                NSAssert1(0, @"errror -'%s'", sqlite3_errmsg(database));
            }
		}
	}
	return con;
}

- (sqlite3 *)getDatabase {
    
    return database;
}


@end

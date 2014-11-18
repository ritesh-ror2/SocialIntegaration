//
//  Database.h
//  Babiinet
//
//  Created by FxByte on 21/08/14.
//  Copyright (c) 2014 FxByte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Database : NSObject

+ (Database *)connection;
- (sqlite3 *)getDatabase;

@end

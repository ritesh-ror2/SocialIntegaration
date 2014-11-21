//
//  ShowUserViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowUserViewController : UIViewController

@property (nonatomic, strong) NSString *searchKeywordType;
@property (nonatomic, strong) NSString *socialType;
@property (nonatomic, strong) IBOutlet UITableView *tbleVwUser;

@end

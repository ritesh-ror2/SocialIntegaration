//
//  ViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableCell.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, IGSessionDelegate, IGRequestDelegate, CustomTableCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tbleVwPostList;
@property (nonatomic, strong) IBOutlet UIImageView *imgVwBackground;

@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) UINavigationItem *navItem;
@property (strong, nonatomic) UINavigationController *navController;
@property (nonatomic)BOOL isAlreadyTapped;



@end

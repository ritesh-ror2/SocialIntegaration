//
//  ViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, IGSessionDelegate, IGRequestDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tbleVwPostList;
@end

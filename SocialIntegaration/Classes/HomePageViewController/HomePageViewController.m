//
//  HomePageViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 12/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "HomePageViewController.h"
#import "ViewController.h"

@interface HomePageViewController () {

    ViewController* vc;
}

@end

@implementation HomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Login Btn tapped

- (IBAction)loginBtnTapped:(id)sender {

    [self performSegueWithIdentifier:@"Tabbar" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"Tabbar"]){

         vc = [segue destinationViewController];
    }
}

@end

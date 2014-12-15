//
//  LoginViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 12/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"

@interface LoginViewController () {

    ViewController* vc;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnTapeed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginBtnTapped:(id)sender  {

    [self performSegueWithIdentifier:@"Tabbar" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"Tabbar"]){
        vc = [segue destinationViewController];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

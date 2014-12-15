//
//  HomePageViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 12/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "HomePageViewController.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "LinkViewController.h"
#import "SignUpViewController.h"

@interface HomePageViewController () {

    ViewController* vc;
    LoginViewController *vwController;
    SignUpViewController *vwControllerSignUp;
    LinkViewController *viewControllerLink;

    NSString*strSignUp;
}

@end

@implementation HomePageViewController

#pragma mark - View life cycle

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

#pragma mark - Login Btn tapped

- (IBAction)loginBtnTapped:(id)sender {

    [self performSegueWithIdentifier:@"linklogin" sender:sender];

  /*  UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *vwController = [storyBoard instantiateViewControllerWithIdentifier:@"loginuser"];
    [self.navigationController pushViewController:vwController animated:YES];*/

        // [self performSegueWithIdentifier:@"Tabbar" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:@"linklogin"]){
        viewControllerLink = [segue destinationViewController];
    } else if ([segueIdentifier isEqualToString:@"signup"]){
        vwControllerSignUp = [segue destinationViewController];
    }
}

- (IBAction)signUpBtnTapped:(id)sender {

    [self performSegueWithIdentifier:@"signup" sender:sender];
}

@end

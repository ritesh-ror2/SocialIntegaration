//
//  SignUpViewController.m
//  SocialIntegaration
//
//  Created by GrepRuby on 12/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "SignUpViewController.h"
#import "LinkViewController.h"
#import "ViewController.h"

@interface SignUpViewController () {

    ViewController *viewControllerTimeline;
    LinkViewController *viewControllerLink;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backBtnTapeed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSString * segueIdentifier = [segue identifier];
    if([segueIdentifier isEqualToString:@"Tabbar"]){
       viewControllerTimeline = [segue destinationViewController];
    } else if ([segueIdentifier isEqualToString:@"link"]){
       viewControllerLink = [segue destinationViewController];
    }
}

- (IBAction)nextBtnTapped:(id)sender {

    [self performSegueWithIdentifier:@"link" sender:sender];
}

@end

//
//  AppDelegate.m
//  SocialIntegaration
//
//  Created by GrepRuby on 06/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import "AppDelegate.h"
#import "StatrtPageControllViewController.h"
#import "FeedPagesViewController.h"

@implementation AppDelegate

@synthesize fbSession,hasFacebook,instagram,InstagramId,undoManager,window;
@synthesize arryOfInstagrame, arryOfFBNewsFeed, arryOfTwittes, arryOfAllFeeds;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    self.instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    self.hasFacebook = NO;
    self.isFirstTimeLaunch = YES;
    //loading view
	self.spinner = [[MBProgressHUD alloc] init];
    [self.window addSubview:self.spinner];
    [self.window bringSubviewToFront:self.spinner];

    // allocate all three array
    self.arryOfFBNewsFeed = [[NSMutableArray alloc]init];
    self.arryOfTwittes = [[NSMutableArray alloc]init];
    self.arryOfInstagrame = [[NSMutableArray alloc]init];
    self.arryOfAllFeeds = [[NSMutableArray alloc]init];

    BOOL isInstalled = [[NSUserDefaults standardUserDefaults]boolForKey:@"IsInstalled"];

    if(isInstalled == NO) {

        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"IsInstalled"];
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        self.vwControllerWelcome = (WelcomeViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"WelcomeViewController"];
        [navigationController pushViewController:self.vwControllerWelcome animated:NO];
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

        //sharedAppDelegate.isFirstTimeLaunch = NO;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

    // YOU NEED TO CAPTURE igAPPID:// schema
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.instagram handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.instagram handleOpenURL:url];
}


- (void)applicationWillTerminate:(UIApplication *)application {

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

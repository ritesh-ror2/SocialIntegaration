//
//  WelcomeViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 12/12/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WelcomeScreenView.h"


@interface WelcomeViewController : UIViewController <WelcomeScreenDelegate> {

    WelcomeScreenView *welcomeScreenVw;
}

@end

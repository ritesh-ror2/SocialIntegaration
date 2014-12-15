//
//  LinkViewController.h
//  SocialIntegaration
//
//  Created by GrepRuby on 13/11/14.
//  Copyright (c) 2014 GrepRuby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkViewController : UIViewController {

    IBOutlet UIView *vwFB;
    IBOutlet UIView *vwTwitter;
    IBOutlet UIView *vwInstagram;

    IBOutlet UIImageView *imgVwFB;
    IBOutlet UIImageView *imgVwTwitter;
    IBOutlet UIImageView *imgVwInstagram;

    IBOutlet UIImageView *imgVwFBCircle;
    IBOutlet UIImageView *imgVwTwitterCircle;
    IBOutlet UIImageView *imgVwInstagramCircle;

    IBOutlet UIButton *btnFb;
    IBOutlet UIButton *btnTwitter;
    IBOutlet UIButton *btnInstagram;

    IBOutlet UIButton *btnFbAdd;
    IBOutlet UIButton *btnTwitterAdd;
    IBOutlet UIButton *btnInstagramAdd;

    IBOutlet UILabel *lblFBName;
    IBOutlet UILabel *lblTwitterName;
    IBOutlet UILabel *lblInstagramName;

    IBOutlet UILabel *lblFBTitle;
    IBOutlet UILabel *lblTwitterTitle;
    IBOutlet UILabel *lblInstagramTitle;
}

@end

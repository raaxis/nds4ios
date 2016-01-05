//
//  NDSSideBarViewController.h
//  nds4ios
//
//  Created by David Chavez on 7/8/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SASlideMenuViewController.h"
#import "SASlideMenuDataSource.h"

@interface NDSSideBarViewController : SASlideMenuViewController {
    IBOutlet UILabel *romListLabel;
    IBOutlet UILabel *aboutLabel;
    IBOutlet UILabel *settingsLabel;
    IBOutlet UILabel *donateLabel;
}


@end

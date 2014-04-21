//
//  NDSSideBarViewController.m
//  nds4ios
//
//  Created by Developer on 7/8/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSSideBarViewController.h"

@interface NDSSideBarViewController ()

@end

@implementation NDSSideBarViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    romListLabel.text = NSLocalizedString(@"ROM List", "ROM List menu item");
    aboutLabel.text = NSLocalizedString(@"About nds4ios", "About nds4ios menu item");
    settingsLabel.text = NSLocalizedString(@"Settings", "Settings menu item");
    donateLabel.text = NSLocalizedString(@"Donate", "Donate menu item");
}

#pragma mark -
#pragma mark SASlideMenuDataSource
// The SASlideMenuDataSource is used to provide the initial segueid that represents the initial visibile view controller and to provide eventual additional configuration to the menu button

// This is the indexPath selected at start-up
-(NSIndexPath*) selectedIndexPath{
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

-(NSString*) segueIdForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return @"romList";
    }else if (indexPath.row == 1){
        return @"about";
    }else if (indexPath.row == 2){
        return @"settings";
    }else {
        return @"donate";
    }
}

-(Boolean) allowContentViewControllerCachingForIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(Boolean) disablePanGestureForIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// This is used to configure the menu button. The beahviour of the button should not be modified
-(void) configureMenuButton:(UIButton *)menuButton{
    menuButton.frame = CGRectMake(0, 0, 40, 29);
    [menuButton setImage:[UIImage imageNamed:@"menuicon.png"] forState:UIControlStateNormal];
}

//restricts pan gesture interation to 50px on the left and right of the view.
-(Boolean) shouldRespondToGesture:(UIGestureRecognizer*) gesture forIndexPath:(NSIndexPath*)indexPath {
    CGPoint touchPosition = [gesture locationInView:self.view];
    return (touchPosition.x < 50.0 || touchPosition.x > self.view.bounds.size.width - 50.0f);
}

-(CGFloat) leftMenuVisibleWidth{
    return 280;
}

-(CGFloat) rightMenuVisibleWidth{
    return 280;
}

@end
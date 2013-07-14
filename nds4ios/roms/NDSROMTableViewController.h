//
//  NDSMasterViewController.h
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSTFileBrowserViewController.h"
#import "NDSEmulatorViewController.h"
#import "OLGhostAlertView.h"
#import <DropboxSDK/DropboxSDK.h>

@interface NDSROMTableViewController : RSTFileBrowserViewController
{
    OLGhostAlertView *resumeGame;
    BOOL isAway;
    //DBPath *saveDir;
}

@end

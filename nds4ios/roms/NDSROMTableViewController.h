//
//  NDSMasterViewController.h
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DocWatchHelper.h"
#import "RSTWebViewController.h"
#import "DownloadManager.h"

@interface NDSROMTableViewController : UITableViewController <RSTWebViewControllerDownloadDelegate, RSTWebViewControllerDelegate, DownloadManagerDelegate>
{
    NSArray *games;
    DocWatchHelper *docWatchHelper;
    
    IBOutlet UINavigationItem *romListTitle;
}

- (void)reloadGames:(NSNotification*)aNotification;

@end

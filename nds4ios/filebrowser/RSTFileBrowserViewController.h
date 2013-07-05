//
//  RSTFileBrowserViewController.h
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSTFileBrowserViewController;

@protocol RSTFileBrowserViewControllerControllerDelegate <NSObject>
@optional

- (void)fileBrowserViewController:(RSTFileBrowserViewController *)fileBrowserViewController didRefreshDirectory:(NSString *)directory;

@end

@interface RSTFileBrowserViewController : UITableViewController

@property (weak, nonatomic) id <RSTFileBrowserViewControllerControllerDelegate> delegate;

@property (copy, nonatomic) NSString *currentDirectory;

@property (assign, nonatomic) BOOL showFileExtensions; // Defaults to NO

@property (copy, nonatomic) NSArray *supportedFileExtensions; // If nil, shows all files

@property (assign, nonatomic) BOOL showFolders; // Defaults to NO

- (void)refreshDirectory; // Refreshes directory (no duh)

- (NSString *)filepathForIndexPath:(NSIndexPath *)indexPath;

@end

//
//  NDSMasterViewController.m
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "AppDelegate.h"
#import "NDSROMTableViewController.h"
#import "NDSEmulatorViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "CHBgDropboxSync.h"
#import "SASlideMenuRootViewController.h"
#import "NDSRightMenuViewController.h"

@interface NDSROMTableViewController ()

@end

@implementation NDSROMTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:78.0/255.0 green:156.0/255.0 blue:206.0/255.0 alpha:1.0]];
    
    BOOL isDir;
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:[[AppDelegate sharedInstance] batterDir] isDirectory:&isDir])
    {
        [fm createDirectoryAtPath:[[AppDelegate sharedInstance] batterDir] withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"Created Battery");
    }
        
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [CHBgDropboxSync start];
    //using file change observers will probably be better. I'll change this later on.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    games = [NDSGame gamesAtPath:AppDelegate.sharedInstance.documentsPath];
    [self.tableView reloadData];
    //TODO: observe changes in ROMs directory to reload data when it changes
}

#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return games.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NDSGame *game = games[indexPath.row];
    
    cell.textLabel.text = game.title;
    cell.accessoryType = game.numberOfSaveStates > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Select ROMs

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NDSGame *game = games[indexPath.row];
    if (game.numberOfSaveStates > 0) {
        // show right menu with save states
        SASlideMenuRootViewController *slideMenuRoot = (SASlideMenuRootViewController*)self.navigationController.parentViewController;
        NDSRightMenuViewController *rightMenu = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"rightMenu"];
        slideMenuRoot.rightMenu = rightMenu;
        rightMenu.game = game;
        [slideMenuRoot rightMenuAction];
    } else {
        // start new game
        [AppDelegate.sharedInstance startGame:game withSavedState:-1];
    }
}

#pragma mark - Non-UITableView functions

- (IBAction)getMoreRoms:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hey You! Yes, You!", @"")
                                                        message:NSLocalizedString(@"By using this button, you agree to take all responsibility regarding and resulting in, but not limited to, the downloading of ROMs and other software to use in this emulator. InfiniDev and all associated personnel is in no way affiliated with the websites resulting from this Google search.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Got it!", @"")
                                              otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com/search?hl=en&source=hp&q=download+ROMs+nds+nintendo+ds&aq=f&oq=&aqi="]];
}

@end
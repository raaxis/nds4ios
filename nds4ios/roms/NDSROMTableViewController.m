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
    
    if (![fm fileExistsAtPath:AppDelegate.sharedInstance.batteryDir isDirectory:&isDir])
    {
        [fm createDirectoryAtPath:AppDelegate.sharedInstance.batteryDir withIntermediateDirectories:NO attributes:nil error:nil];
        NSLog(@"Created Battery");
    } else {
        // move saved states from documents into battery directory
        for (NSString *file in [fm contentsOfDirectoryAtPath:AppDelegate.sharedInstance.documentsPath error:NULL]) {
            if ([file.pathExtension isEqualToString:@"dsv"]) {
                NSError *err = nil;
                [fm moveItemAtPath:[AppDelegate.sharedInstance.documentsPath stringByAppendingPathComponent:file]
                            toPath:[AppDelegate.sharedInstance.batteryDir stringByAppendingPathComponent:file]
                             error:&err];
                if (err) NSLog(@"Could not move %@ to battery dir: %@", file, err);
            }
        }
    }
    
    // Localize the title
    romListTitle.title = NSLocalizedString(@"ROM List", nil);
    
    // watch for changes in documents folder
    docWatchHelper = [DocWatchHelper watcherForPath:AppDelegate.sharedInstance.documentsPath];
    
    // register for notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(reloadGames:) name:NDSGameSaveStatesChangedNotification object:nil];
    [nc addObserver:self selector:@selector(reloadGames:) name:kDocumentChanged object:docWatchHelper];
    
    [self reloadGames:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [CHBgDropboxSync start];
    //TODO: add back the + button, but just have it pop up this UIAlert instead
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IMPORTANT"
                                                        message:@"We have recently removed the '+' button from nds4ios for safety reasons. If you are unsure how to add ROMs to nds4ios, please tap on 'Tutorial'. Otherwise, Tap on 'OK' to dismiss this one-time dialog."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Tutorial", nil];
        [alert show];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)reloadGames:(NSNotification*)aNotification
{
    NSUInteger row = [aNotification.object isKindOfClass:[NDSGame class]] ? [games indexOfObject:aNotification.object] : NSNotFound;
    if (aNotification.object == docWatchHelper) {
        // do it later, the file may not be written yet
        [self performSelector:_cmd withObject:nil afterDelay:2.5];
    }
    if (aNotification == nil || row == NSNotFound) {
        // reload all games
        games = [NDSGame gamesAtPath:AppDelegate.sharedInstance.documentsPath saveStateDirectoryPath:AppDelegate.sharedInstance.batteryDir];
        [self.tableView reloadData];
    } else {
        // reload single row
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NDSGame *game = games[indexPath.row];
        if ([[NSFileManager defaultManager] removeItemAtPath:game.path error:NULL]) {
            games = [NDSGame gamesAtPath:AppDelegate.sharedInstance.documentsPath saveStateDirectoryPath:AppDelegate.sharedInstance.batteryDir];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
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
    
    if (game.gameTitle) {
        // use title from ROM
        NSArray *titleLines = [game.gameTitle componentsSeparatedByString:@"\n"];
        cell.textLabel.text = titleLines[0];
        cell.detailTextLabel.text = titleLines.count >= 1 ? titleLines[1] : nil;
    } else {
        // use filename
        cell.textLabel.text = game.title;
        cell.detailTextLabel.text = nil;
    }
    
    cell.imageView.image = game.icon;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//#pragma mark - Non-UITableView functions

#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    if( buttonIndex == 1 )
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/raaxis/nds4ios#adding-roms-to-nds4ios"]];
    }
}


@end
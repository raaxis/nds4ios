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
#import "RSTWebViewController.h"
#import "DownloadManager.h"
#import "DownloadCell.h"
#import "ZAActivityBar.h"
#import "SSZipArchive.h"

@interface NDSROMTableViewController () <DownloadManagerDelegate>

@property (strong, nonatomic) DownloadManager *downloadManager;
@property (nonatomic) int downloadCount;
@property (nonatomic) BOOL isDownloading;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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
    return (self.isDownloading)?NO:YES;
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
    return (self.isDownloading)?games.count+1:games.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isDownloading && indexPath.row == games.count) {
        DownloadCell *downloadCell  = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell"];
        [downloadCell.activityIndicator startAnimating];
        return downloadCell;
    } else
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
}

#pragma mark - Select ROMs

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isDownloading && indexPath.row == games.count) {
        [self.downloadManager cancelAll];
        [ZAActivityBar showSuccessWithStatus:@"Cancelled Download!" duration:3];
        [self.tableView reloadData];
    } else
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Non-UITableView functions

- (IBAction)getMoreRoms:(id)sender
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"showedDownloadWarning"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hey You! Yes, You!", @"")
                                                        message:NSLocalizedString(@"By using this button, you agree to take all responsibility regarding and resulting in, but not limited to, the downloading of Nintendo DS software to use in this emulator. Please support the software developers and do not pirate their hard work. Dumping ROMs yourself is still the best, and recommended way to go. InfiniDev and all associated personnel do not condone the act of piracy.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Got it!", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showedDownloadWarning"];
    } else
    {
        RSTWebViewController *webView = [[RSTWebViewController alloc] initWithAddress:@"http://m.coolrom.com/roms/nds/?utm_source=nds4ios&utm_medium=partnerships&utm_campaign=nds4ios"];
        webView.showsDoneButton = YES;
        webView.downloadDelegate = self;
        webView.delegate = self;
        [[UIApplication sharedApplication] setStatusBarStyle:[webView preferredStatusBarStyle] animated:YES];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webView];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        RSTWebViewController *webView = [[RSTWebViewController alloc] initWithAddress:@"http://m.coolrom.com/roms/nds/?utm_source=nds4ios&utm_medium=partnerships&utm_campaign=nds4ios"];
        webView.showsDoneButton = YES;
        webView.downloadDelegate = self;
        webView.delegate = self;
        [[UIApplication sharedApplication] setStatusBarStyle:[webView preferredStatusBarStyle] animated:YES];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webView];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - web view delegate


#pragma mark - downloader delegate

// Return YES to indicate you want to intercept the request and possibly perform a download
- (BOOL)webViewController:(RSTWebViewController *)webViewController shouldInterceptDownloadRequest:(NSURLRequest *)request
{
    //sorry riley, i won't be using your built in downloader :( but thanks for providing the web viewer :D
    
    BOOL shouldDownload = NO;
    BOOL fromCoolRom = NO;
    //regular URLs with regular file extensions
    if ([[NSString stringWithFormat:@"%@", request.URL].lowercaseString hasSuffix:@".zip"] || [[NSString stringWithFormat:@"%@", request.URL].lowercaseString hasSuffix:@".nds"]) {
        shouldDownload = YES;
    }
    
    //CoolRoms specific URLs with no extensions godammit coolrom
    if (([request.URL.host.lowercaseString rangeOfString:@"m.coolrom"].location == NSNotFound && [request.URL.host.lowercaseString rangeOfString:@".coolrom"].location != NSNotFound)) {
        shouldDownload = YES;
        fromCoolRom = YES;
    }
    
    if (shouldDownload) {
        
        // create download manager instance
        
        if (!self.downloadManager) self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        self.downloadManager.maxConcurrentDownloads = 4;
        
        // doooownload
        
        NSString *downloadFilename = [NSString stringWithFormat:@"%@/%@%@", AppDelegate.sharedInstance.documentsPath, request.URL.lastPathComponent, (fromCoolRom)?@".zip":@""];
        
        [self.downloadManager addDownloadWithFilename:downloadFilename URL:request.URL];
        self.downloadCount++;
        
        [self.downloadManager start];
        self.isDownloading = YES;
        [self.tableView reloadData];
        
        [webViewController dismissModalViewControllerAnimated:YES];
    }
    
    return NO;
}

// Call startDownloadBlock once you or the user has decided whether to download a file. Pass in YES as the first argument to continue with the download, or NO to cancel it.
// Optionally, pass in an NSProgress object to be used to track progress of the download.
- (void)webViewController:(RSTWebViewController *)webViewController shouldStartDownloadTask:(NSURLSessionDownloadTask *)downloadTask startDownloadBlock:(RSTWebViewControllerStartDownloadBlock)startDownloadBlock
{
    //nope
}

// Called once download has completed. You must move the file from the destinationURL by the time the method returns if you want to keep onto it, since iOS will delete it soon after.
- (void)webViewController:(RSTWebViewController *)webViewController didCompleteDownloadTask:(NSURLSessionDownloadTask *)downloadTask destinationURL:(NSURL *)url error:(NSError *)error
{
    //nope
}

#pragma mark - Download Manager delegate

- (void)didFinishLoadingAllForManager:(DownloadManager *)downloadManager
{
    [ZAActivityBar showSuccessWithStatus:[NSString stringWithFormat:@"All files downloaded successfully!"] duration:3];
    self.isDownloading = NO;
    self.downloadCount = 0;
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
{
    [ZAActivityBar showSuccessWithStatus:[NSString stringWithFormat:@"%@ downloaded successfully!", download.filename] duration:3];
    self.downloadCount--;
    self.isDownloading = NO;
    
    //check for zip
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([download.filename.lowercaseString rangeOfString:@"zip"].location != NSNotFound) {
        
        for (NSString *path in [fm subpathsAtPath:[AppDelegate sharedInstance].documentsPath])
        {
            if ([path.lowercaseString rangeOfString:@".zip"].location != NSNotFound) {
                [SSZipArchive unzipFileAtPath:[NSString stringWithFormat:@"%@/%@", [AppDelegate sharedInstance].documentsPath, path] toDestination:[AppDelegate sharedInstance].documentsPath];
                [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [AppDelegate sharedInstance].documentsPath, path] error:NULL];
            }
        }
        
        //after unzip, go through it again to remove/remove other files
        for (NSString *path in [fm subpathsAtPath:[AppDelegate sharedInstance].documentsPath])
        {
            if ([path.lowercaseString rangeOfString:@".dsv"].location != NSNotFound) {
                [fm moveItemAtPath:[NSString stringWithFormat:@"%@/%@", [AppDelegate sharedInstance].documentsPath, path] toPath:[NSString stringWithFormat:@"%@/%@", [AppDelegate sharedInstance].documentsPath, @"Battery"] error:nil];
            } else if ([path.lowercaseString rangeOfString:@".html"].location != NSNotFound || [path.lowercaseString rangeOfString:@".nfo"].location != NSNotFound || [path.lowercaseString rangeOfString:@".txt"].location != NSNotFound || [path rangeOfString:@".rtf"].location != NSNotFound || [path.lowercaseString rangeOfString:@".README"].location != NSNotFound)
            {
                [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [AppDelegate sharedInstance].documentsPath, path] error:NULL];
            }
        }
    }
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;
{
    NSLog(@"%s %@ error=%@", __FUNCTION__, download.filename, download.error);
    
    [ZAActivityBar showErrorWithStatus:[NSString stringWithFormat:@"%@ failed to download! %@", download.filename, download.error] duration:4];
    self.isDownloading = NO;
    self.downloadCount = 0;
    [self.tableView reloadData];
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;
{
    if (self.isDownloading) {
        DownloadCell *cell = (DownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:games.count inSection:0]];
        [cell.progressView setProgress:(float)download.progressContentLength / (float)download.expectedContentLength animated:YES];
        cell.filenameLabel.text = [NSString stringWithFormat:@"Downloading %i %@", self.downloadCount, (self.downloadCount > 1)?[NSString stringWithFormat:@"ROMs. Progress for %@:", download.filename]:@"ROM"];
    }
}

@end
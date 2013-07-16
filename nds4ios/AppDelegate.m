//
//  AppDelegate.m
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "AppDelegate.h"
#import "SSZipArchive.h"
#import <DropboxSDK/DropboxSDK.h>
#import "OLGhostAlertView.h"
#import "CHBgDropboxSync.h"
#import "SASlideMenuRootViewController.h"

@implementation AppDelegate

+ (AppDelegate*)sharedInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    
    //Dropbox DBSession Auth
    //You must insert the app key and secret here for Dropbox to work!
    NSString* appKey = @"APP_KEY";
	NSString* appSecret = @"APP_SECRET";
    
    NSString* errorMsg = nil;
	if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"You must set the App Key correctly for Dropbox to work!";
	} else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"You must set the App Secret correctly for Dropbox to work!";
	} else {
		NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
		NSDictionary *loadedPlist =
        [NSPropertyListSerialization
         propertyListFromData:plistData mutabilityOption:0 format:NULL errorDescription:NULL];
		NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
		if ([scheme isEqual:@"db-APP_KEY"]) {
			errorMsg = @"You must set the URL Scheme correctly in nds4ios-Info.plist for Dropbox to work!";
		}
	}
    
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
    if (errorMsg != nil) {
		[[[UIAlertView alloc]
		   initWithTitle:@"Error Configuring Dropbox" message:errorMsg
		   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
		 show];
	}
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[[NSString stringWithFormat:@"%@", url] substringToIndex:2] isEqualToString: @"db"]) {
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            if ([[DBSession sharedSession] isLinked]) {
                OLGhostAlertView *linkSuccess = [[OLGhostAlertView alloc] initWithTitle:@"Success!" message:@"Dropbox was linked successfully! nds4ios will now start syncing your saves to a Dropbox folder called 'nds4ios' located in the root directory of your Dropbox folder." timeout:15 dismissible:YES];
                [linkSuccess show];
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"enableDropbox"];
                
                [CHBgDropboxSync clearLastSyncData];
                [CHBgDropboxSync start];
            }
            return YES;
        }
    } else if (url) {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        [SSZipArchive unzipFileAtPath:[url path] toDestination:documentsDirectory];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"Inbox"] error:NULL];
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathExtension:@".html"] error:NULL];
        return YES;
    }
    return NO;
}

- (NSString *)batterDir
{
    NSString* batteryDir = [NSString stringWithFormat:@"%@/Battery", self.documentsPath];
    return batteryDir;
}

- (NSString *)documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)startGame:(NDSGame *)game withSavedState:(NSInteger)savedState
{
    // TODO: check if resuming current game, also call EMU_closeRom maybe
    NDSEmulatorViewController *emulatorViewController = (NDSEmulatorViewController *)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"emulatorView"];
    emulatorViewController.game = game;
    emulatorViewController.loadSaveState = [game pathForSaveStateAtIndex:savedState];
    [AppDelegate sharedInstance].currentEmulatorViewController = emulatorViewController;
    SASlideMenuRootViewController *rootViewController = (SASlideMenuRootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController doSlideIn:nil];
    [rootViewController presentModalViewController:emulatorViewController animated:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [CHBgDropboxSync start];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

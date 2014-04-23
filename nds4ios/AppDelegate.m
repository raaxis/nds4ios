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
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    else
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    
    //Dropbox DBSession Auth
    
    NSString* errorMsg = nil;
	if ([[self appKey] rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
		errorMsg = @"You must set the App Key correctly for Dropbox to work!";
	} else if ([[self appSecret] rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
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
    
    DBSession* dbSession = [[DBSession alloc] initWithAppKey:[self appKey] appSecret:[self appSecret] root:kDBRootAppFolder];
    [DBSession setSharedSession:dbSession];
    
    if (errorMsg != nil) {
		[[[UIAlertView alloc]
		   initWithTitle:NSLocalizedString(@"Error Configuring Dropbox", @"") message:errorMsg
		   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]
		 show];
	}
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([[[NSString stringWithFormat:@"%@", url] substringToIndex:2] isEqualToString: @"db"]) {
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            if ([[DBSession sharedSession] isLinked]) {
                OLGhostAlertView *linkSuccess = [[OLGhostAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", @"") message:NSLocalizedString(@"Dropbox was linked successfully! nds4ios will now start syncing your saves to a Dropbox folder called 'nds4ios' located in the root directory of your Dropbox folder.", @"") timeout:15 dismissible:YES];
                [linkSuccess show];
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"enableDropbox"];
                
                [CHBgDropboxSync clearLastSyncData];
                [CHBgDropboxSync start];
            }
            return YES;
        }
    } else if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path] && [url.path.stringByDeletingLastPathComponent.lastPathComponent isEqualToString:@"Inbox"]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *err = nil;
        if ([url.pathExtension.lowercaseString isEqualToString:@"zip"]) {
            // expand zip
            // create directory to expand
            NSString *dstDir = [NSTemporaryDirectory() stringByAppendingPathComponent:url.path.lastPathComponent];
            if ([fm createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:&err] == NO) {
                NSLog(@"Could not create directory to expand zip: %@ %@", dstDir, err);
                [fm removeItemAtURL:url error:NULL];
                return NO;
            }
            
            // expand
            [SSZipArchive unzipFileAtPath:url.path toDestination:dstDir];
            
            // move .nds to documents and .dsv to battery
            for (NSString *path in [fm subpathsAtPath:dstDir]) {
                if ([path.pathExtension.lowercaseString isEqualToString:@"nds"]) {
                    NSLog(@"found ROM in zip: %@", path);
                    [fm moveItemAtPath:[dstDir stringByAppendingPathComponent:path] toPath:[self.documentsPath stringByAppendingPathComponent:path.lastPathComponent] error:NULL];
                } else if ([path.pathExtension.lowercaseString isEqualToString:@"dsv"]) {
                    NSLog(@"found save in zip: %@", path);
                    [fm moveItemAtPath:[dstDir stringByAppendingPathComponent:path] toPath:[self.batteryDir stringByAppendingPathComponent:path.lastPathComponent] error:NULL];
                }
            }
            
            // remove unzip dir
            [fm removeItemAtPath:dstDir error:NULL];
        } else if ([url.pathExtension.lowercaseString isEqualToString:@"nds"]) {
            // move to documents
            [fm moveItemAtPath:url.path toPath:[self.documentsPath stringByAppendingPathComponent:url.lastPathComponent] error:&err];
        }
        
        // remove inbox (shouldn't be needed)
        [fm removeItemAtPath:[self.documentsPath stringByAppendingPathComponent:@"Inbox"] error:NULL];
        
        return YES;
    }
    return NO;
}

- (NSString *)batteryDir
{
    return [self.documentsPath stringByAppendingPathComponent:@"Battery"];
}

- (NSString *)documentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *)appKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"dbAppKey"];
}

- (NSString *)appSecret
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"dbAppSecret"];
}

- (void)startGame:(NDSGame *)game withSavedState:(NSInteger)savedState
{
    // TODO: check if resuming current game, also call EMU_closeRom maybe
    NDSEmulatorViewController *emulatorViewController = (NDSEmulatorViewController *)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"emulatorView"];
    emulatorViewController.game = game;
    emulatorViewController.saveState = [game pathForSaveStateAtIndex:savedState];
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

//
//  AppDelegate.m
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "AppDelegate.h"
#import "SSZipArchive.h"
#import <Dropbox/Dropbox.h>
#import "OLGhostAlertView.h"

@implementation AppDelegate

+ (AppDelegate*)sharedInstance
{
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
    self.gameOpen = NO;
    
    //dropbox
    
    DBAccountManager* accountMgr = [[DBAccountManager alloc] initWithAppKey:@"si4f6nnhrhl1ftc" secret:@"w7c03bp86hmh54q"];
    //please don't steal the app key and app secret <3
    [DBAccountManager setSharedManager:accountMgr];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    NSLog(@"%@", url);
    if ([[[NSString stringWithFormat:@"%@", url] substringToIndex:2] isEqualToString: @"db"]/*account*/) {
        if (account) {
            OLGhostAlertView *linkSuccess = [[OLGhostAlertView alloc] initWithTitle:@"Success!" message:@"Dropbox was linked successfully! nds4ios will now start syncing your saves to a Dropbox folder called 'nds4ios' located in the root directory of your Dropbox folder." timeout:15 dismissible:YES];
            [linkSuccess show];
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"enableDropbox"];
            return YES;
        }
    } else if (url) {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        [SSZipArchive unzipFileAtPath:[url path] toDestination:documentsDirectory];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"Inbox"] error:NULL];
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathExtension:@".html"] error:NULL];
    }
    return YES;
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

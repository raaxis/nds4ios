//
//  AppDelegate.h
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDSEmulatorViewController.h"
#import "NDSGame.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NDSGame *currentGame;
@property (strong, nonatomic) NDSEmulatorViewController *currentEmulatorViewController;

+ (AppDelegate *)sharedInstance;

- (NSString *)batteryDir;
- (NSString *)documentsPath;

- (void)startGame:(NDSGame *)game withSavedState:(NSInteger)savedState;

@end
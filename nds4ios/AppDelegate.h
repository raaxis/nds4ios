//
//  AppDelegate.h
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDSEmulatorViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL gameOpen;
@property (nonatomic) NSString *currentGame;
@property (strong, nonatomic) NDSEmulatorViewController *currentEmulatorViewController;

+ (AppDelegate *)sharedInstance;

@end

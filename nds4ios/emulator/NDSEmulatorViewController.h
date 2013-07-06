//
//  NDSEmulatorViewController.h
//  nds4ios
//
//  Created by InfiniDev on 6/11/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDSDirectionalControl.h"
#import "NDSButtonControl.h"

@interface NDSEmulatorViewController : UIViewController

@property (copy, nonatomic) NSString *romFilepath;
@property (weak, nonatomic) IBOutlet NDSDirectionalControl *directionalControl;
@property (weak, nonatomic) IBOutlet NDSButtonControl *buttonControl;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) UIImageView *snapshotView;

- (void)pauseEmulation;
- (void)resumeEmulation;
- (IBAction)hideEmulator:(id)sender;

@end

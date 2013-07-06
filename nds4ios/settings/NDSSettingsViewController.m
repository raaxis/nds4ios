//
//  Settings.m
//  nds4ios
//
//  Created by Riley Testut on 7/5/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSSettingsViewController.h"

@implementation NDSSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissSettingsViewController:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)controlChanged:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (sender == self.frameSkipControl) {
        NSInteger frameSkip = self.frameSkipControl.selectedSegmentIndex;
        if (frameSkip == 5) frameSkip = -1;
        [defaults setInteger:frameSkip forKey:@"frameSkip"];
    } else if (sender == self.disableSoundSwitch) {
        [defaults setBool:self.disableSoundSwitch.on forKey:@"disableSound"];
    } else if (sender == self.controlPadStyleControl) {
        [defaults setInteger:self.controlPadStyleControl.selectedSegmentIndex forKey:@"controlPadStyle"];
    } else if (sender == self.controlPositionControl) {
        [defaults setInteger:self.controlPadStyleControl.selectedSegmentIndex forKey:@"controlPosition"];
    } else if (sender == self.controlOpacitySlider) {
        [defaults setFloat:self.controlOpacitySlider.value forKey:@"controlOpacity"];
    } else if (sender == self.showFPSSwitch) {
        [defaults setBool:self.showFPSSwitch.on forKey:@"showFPS"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger frameSkip = [defaults integerForKey:@"frameSkip"];
    self.frameSkipControl.selectedSegmentIndex = frameSkip < 0 ? 5 : frameSkip;
    self.disableSoundSwitch.on = [defaults boolForKey:@"disableSound"];
    
    self.controlPadStyleControl.selectedSegmentIndex = [defaults integerForKey:@"controlPadStyle"];
    self.controlPositionControl.selectedSegmentIndex = [defaults integerForKey:@"controlPosition"];
    self.controlOpacitySlider.value = [defaults floatForKey:@"controlOpacity"];
    
    self.showFPSSwitch.on = [defaults boolForKey:@"showFPS"];
}

@end

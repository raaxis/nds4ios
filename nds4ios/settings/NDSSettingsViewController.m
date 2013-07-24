//
//  Settings.m
//  nds4ios
//
//  Created by Riley Testut on 7/5/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSSettingsViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "OLGhostAlertView.h"
#import "CHBgDropboxSync.h"

@interface NDSSettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *frameSkipControl;
@property (weak, nonatomic) IBOutlet UISwitch *disableSoundSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *controlPadStyleControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *controlPositionControl;
@property (weak, nonatomic) IBOutlet UISlider *controlOpacitySlider;

@property (weak, nonatomic) IBOutlet UISwitch *showFPSSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableJITSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *dropboxSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cellularSwitch;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

- (IBAction)controlChanged:(id)sender;

@end

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
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:78.0/255.0 green:156.0/255.0 blue:206.0/255.0 alpha:1.0]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    UIView *hiddenSettingsTapView = [[UIView alloc] initWithFrame:CGRectMake(245, 0, 75, 44)];
    
    UIBarButtonItem *hiddenSettingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hiddenSettingsTapView];
    self.navigationItem.rightBarButtonItem = hiddenSettingsBarButtonItem;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(revealHiddenSettings:)];
    tapGestureRecognizer.numberOfTapsRequired = 3;
    [hiddenSettingsTapView addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [defaults setInteger:self.controlPositionControl.selectedSegmentIndex forKey:@"controlPosition"];
    } else if (sender == self.controlOpacitySlider) {
        [defaults setFloat:self.controlOpacitySlider.value forKey:@"controlOpacity"];
    } else if (sender == self.showFPSSwitch) {
        [defaults setBool:self.showFPSSwitch.on forKey:@"showFPS"];
    } else if (sender == self.enableJITSwitch) {
        [defaults setBool:self.enableJITSwitch.on forKey:@"enableLightningJIT"];
    } else if (sender == self.dropboxSwitch) {//i'll use a better more foolproof method later
        if ([defaults boolForKey:@"enableDropbox"] == false) {
            [[DBSession sharedSession] linkFromController:self];
        } else {
            NSLog(@"unlink");
            [CHBgDropboxSync forceStopIfRunning];
            [CHBgDropboxSync clearLastSyncData];
            [[DBSession sharedSession] unlinkAll];
            OLGhostAlertView *unlinkAlert = [[OLGhostAlertView alloc] initWithTitle:@"Unlinked!" message:@"Dropbox has been unlinked. Your games will no longer be synced." timeout:10 dismissible:YES];
            [unlinkAlert show];

            [defaults setBool:false forKey:@"enableDropbox"];
            self.accountLabel.text = @"Not Linked";
        }
    } else if (sender == self.cellularSwitch) {
        [defaults setBool:self.cellularSwitch.on forKey:@"enableDropboxCellular"];
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
    
    self.enableJITSwitch.on = [defaults boolForKey:@"enableLightningJIT"];
    
    self.dropboxSwitch.on = [defaults boolForKey:@"enableDropbox"];
    self.cellularSwitch.on = [defaults boolForKey:@"enableDropboxCellular"];
    
    if ([defaults boolForKey:@"enableDropbox"] == true) {
        self.accountLabel.text = @"Linked";
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    self.dropboxSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableDropbox"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"enableDropbox"] == true) {
        self.accountLabel.text = @"Linked";
    }
}

#pragma mark - Hidden Settings

- (void)revealHiddenSettings:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"revealHiddenSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"revealHiddenSettings"]) {
        return 5;
    }
    
    return 4;//4
}

@end

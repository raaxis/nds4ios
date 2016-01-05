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

@property (weak, nonatomic) IBOutlet UINavigationItem *settingsTitle;

@property (weak, nonatomic) IBOutlet UILabel *frameSkipLabel;
@property (weak, nonatomic) IBOutlet UILabel *disableSoundLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *frameSkipControl;
@property (weak, nonatomic) IBOutlet UISwitch *disableSoundSwitch;

@property (weak, nonatomic) IBOutlet UILabel *controlPadStyleLabel;
@property (weak, nonatomic) IBOutlet UILabel *controlPositionLabel;
@property (weak, nonatomic) IBOutlet UILabel *controlOpacityLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *controlPadStyleControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *controlPositionControl;
@property (weak, nonatomic) IBOutlet UISlider *controlOpacitySlider;

@property (weak, nonatomic) IBOutlet UILabel *showFPSLabel;
@property (weak, nonatomic) IBOutlet UILabel *showPixelGridLabel;

@property (weak, nonatomic) IBOutlet UISwitch *showFPSSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showPixelGridSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *enableJITSwitch;

@property (weak, nonatomic) IBOutlet UILabel *vibrateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSwitch;

@property (weak, nonatomic) IBOutlet UILabel *dropboxLabel;

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
    
    self.settingsTitle.title = NSLocalizedString(@"Settings", nil);
    
    self.frameSkipLabel.text = NSLocalizedString(@"Frame Skip", nil);
    self.disableSoundLabel.text = NSLocalizedString(@"Disable Sound", nil);
    self.showPixelGridLabel.text = NSLocalizedString(@"Overlay Pixel Grid", nil);

    self.controlPadStyleLabel.text = NSLocalizedString(@"Control Pad Style", nil);
    self.controlPositionLabel.text = NSLocalizedString(@"Controls Position (Portrait)", nil);
    self.controlOpacityLabel.text = NSLocalizedString(@"Control Opacity (Portrait)", nil);
    
    self.dropboxLabel.text = NSLocalizedString(@"Enable Dropbox Sync", nil);
    self.accountLabel.text = NSLocalizedString(@"Not Linked", nil);
    
    self.showFPSLabel.text = NSLocalizedString(@"Show FPS", nil);
    self.vibrateLabel.text = NSLocalizedString(@"Vibration", nil);

    [self.frameSkipControl setTitle:NSLocalizedString(@"Auto", nil) forSegmentAtIndex:5];

    [self.controlPadStyleControl setTitle:NSLocalizedString(@"D-Pad", nil) forSegmentAtIndex:0];
    [self.controlPadStyleControl setTitle:NSLocalizedString(@"Joystick", nil) forSegmentAtIndex:1];

    [self.controlPositionControl setTitle:NSLocalizedString(@"Top", nil) forSegmentAtIndex:0];
    [self.controlPositionControl setTitle:NSLocalizedString(@"Bottom", nil) forSegmentAtIndex:1];
    
    
    UIView *hiddenSettingsTapView = [[UIView alloc] initWithFrame:CGRectMake(245, 0, 75, 44)];
    
    UIBarButtonItem *hiddenSettingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:hiddenSettingsTapView];
    self.navigationItem.rightBarButtonItem = hiddenSettingsBarButtonItem;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(revealHiddenSettings:)];
    tapGestureRecognizer.numberOfTapsRequired = 3;
    [hiddenSettingsTapView addGestureRecognizer:tapGestureRecognizer];
    
}

- (NSString *)tableView:(UITableView *)tableView  titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Emulator", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"Controls", nil);
            break;
        case 2:
            sectionName = @"Dropbox";
            break;
        case 3:
            sectionName = NSLocalizedString(@"Developer", nil);
            break;
        case 4:
            sectionName = NSLocalizedString(@"Experimental", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSString *)tableView:(UITableView *)tableView  titleForFooterInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"The pixel grid makes games appear less blurry, but at the same time, reduces brightness.", nil);
            break;
        case 2:
            sectionName = NSLocalizedString(@"Enabling Dropbox will add an \"nds4ios\" folder to your Dropbox account. Your game saves will be synced back to that folder so it will carry across devices (iPhone, iPad, iPod touch, Android, PC, etc).", nil);
            break;
        case 4:
            sectionName = NSLocalizedString(@"GNU Lightning JIT makes games run faster. You must be jailbroken or nds4ios will crash.", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
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
    } else if (sender == self.showPixelGridSwitch) {
        [defaults setBool:self.showPixelGridSwitch.on forKey:@"showPixelGrid"];
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
    } else if (sender == self.vibrateSwitch) {
        [defaults setBool:self.vibrateSwitch.on forKey:@"vibrate"];
    } else if (sender == self.dropboxSwitch) {//i'll use a better more foolproof method later. <- lol yeah right
        if ([defaults boolForKey:@"enableDropbox"] == false) {
            [[DBSession sharedSession] linkFromController:self];
        } else {
            NSLog(@"unlink");
            [CHBgDropboxSync forceStopIfRunning];
            [CHBgDropboxSync clearLastSyncData];
            [[DBSession sharedSession] unlinkAll];
            OLGhostAlertView *unlinkAlert = [[OLGhostAlertView alloc] initWithTitle:NSLocalizedString(@"Unlinked!", @"") message:NSLocalizedString(@"Dropbox has been unlinked. Your games will no longer be synced.", @"") timeout:10 dismissible:YES];
            [unlinkAlert show];
            
            [defaults setBool:false forKey:@"enableDropbox"];
            self.accountLabel.text = NSLocalizedString(@"Not Linked", nil);
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
    self.showPixelGridSwitch.on = [defaults boolForKey:@"showPixelGrid"];
    
    self.enableJITSwitch.on = [defaults boolForKey:@"enableLightningJIT"];
    self.vibrateSwitch.on = [defaults boolForKey:@"vibrate"];
    
    self.dropboxSwitch.on = [defaults boolForKey:@"enableDropbox"];
    self.cellularSwitch.on = [defaults boolForKey:@"enableDropboxCellular"];
    
    if ([defaults boolForKey:@"enableDropbox"] == true) {
        self.accountLabel.text = NSLocalizedString(@"Linked", @"");
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    self.dropboxSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableDropbox"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"enableDropbox"] == true) {
        self.accountLabel.text = NSLocalizedString(@"Linked", @"");
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

//
//  Settings.h
//  nds4ios
//
//  Created by Riley Testut on 7/5/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSSettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *frameSkipControl;
@property (weak, nonatomic) IBOutlet UISwitch *disableSoundSwitch;

@property (weak, nonatomic) IBOutlet UISegmentedControl *controlPadStyleControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *controlPositionControl;
@property (weak, nonatomic) IBOutlet UISlider *controlOpacitySlider;

@property (weak, nonatomic) IBOutlet UISwitch *showFPSSwitch;

- (IBAction)controlChanged:(id)sender;

@end

//
//  NDSMasterViewController.m
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "AppDelegate.h"
#import "NDSROMTableViewController.h"
#import "NDSEmulatorViewController.h"

#define DOCUMENTS_PATH() [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface NDSROMTableViewController ()

@property (strong, nonatomic) NDSEmulatorViewController *currentEmulatorViewController;

@end

@implementation NDSROMTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.showFileExtensions = NO;
    self.supportedFileExtensions = @[@"nds", @"zip"];
    self.currentDirectory = DOCUMENTS_PATH();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:78.0/255.0 green:156.0/255.0 blue:206.0/255.0 alpha:1.0]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(getMoreROMs)];
    
    BOOL isDir;
    NSString* batteryDir = [NSString stringWithFormat:@"%@/Battery",DOCUMENTS_PATH()];
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:batteryDir isDirectory:&isDir])
        [fm createDirectoryAtPath:batteryDir withIntermediateDirectories:NO attributes:nil error:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self showAlert];
    [AppDelegate sharedInstance].gameOpen = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)showAlert
{
    if ([AppDelegate sharedInstance].gameOpen)
    {
        OLGhostAlertView *resumeGame = [[OLGhostAlertView alloc] initWithTitle:@"Game Backgrounded" message:[NSString stringWithFormat:@"Tap here to resume:\n%@", currentGame] timeout:INFINITY dismissible:YES];
        resumeGame.position = OLGhostAlertViewPositionBottom;
        [resumeGame show];
        resumeGame.completionBlock = ^(void) {
            if (self.currentEmulatorViewController)
            {
                [self presentViewController:self.currentEmulatorViewController animated:YES completion:^(){
                    [self.currentEmulatorViewController resumeEmulation];
                    
                }];
            }
        };
        [resumeGame show];
    }
}

#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark - Select ROMs

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"presentEmulator"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSString *filepath = [self filepathForIndexPath:indexPath];
        currentGame = cell.textLabel.text;
        [AppDelegate sharedInstance].gameOpen = YES;
        self.currentEmulatorViewController = (NDSEmulatorViewController *)[segue destinationViewController];
        self.currentEmulatorViewController.romFilepath = filepath;
    }
}

#pragma mark - Non-UITableView functions

- (void)getMoreROMs
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showedROMAlert"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com/search?hl=en&source=hp&q=download+ROMs+nds+nintendo+ds&aq=f&oq=&aqi="]];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Hey You! Yes, You!", @"")
                                                        message:NSLocalizedString(@"This opens Safari. Simply download the ROM you want, and then 'Open In...' nds4ios. Everything else will be taken care of. You should own the actual cartridge of any ROM you download!", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                              otherButtonTitles:nil];
        [alert show];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showedROMAlert"];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com/search?hl=en&source=hp&q=download+ROMs+nds+nintendo+ds&aq=f&oq=&aqi="]];
}

@end
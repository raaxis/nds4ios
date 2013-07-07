//
//  NDSMasterViewController.m
//  nds4ios
//
//  Created by InfiniDev on 6/9/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSROMTableViewController.h"
#import "NDSEmulatorViewController.h"

@interface NDSROMTableViewController ()

@property (strong, nonatomic) NDSEmulatorViewController *currentEmulatorViewController;

@end

@implementation NDSROMTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    self.currentDirectory = documentsDirectory;
    self.showFileExtensions = NO;
    self.supportedFileExtensions = @[@"nds", @"zip"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([[self filepathForIndexPath:indexPath] isEqualToString:self.currentEmulatorViewController.romFilepath]) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([[self filepathForIndexPath:indexPath] isEqualToString:self.currentEmulatorViewController.romFilepath]) {
        [self presentViewController:self.currentEmulatorViewController animated:YES completion:^(){
            [self.currentEmulatorViewController resumeEmulation];
        }];
    }
}

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
        
        self.currentEmulatorViewController = (NDSEmulatorViewController *)[segue destinationViewController];
        self.currentEmulatorViewController.romFilepath = filepath;
    }
}

@end

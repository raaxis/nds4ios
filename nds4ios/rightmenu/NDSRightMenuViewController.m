//
//  NDSRightMenuViewController.m
//  nds4ios
//
//  Created by David Chavez on 7/15/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSRightMenuViewController.h"
#import "AppDelegate.h"

@interface NDSRightMenuViewController ()

@end

@implementation NDSRightMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.game.title;
}

#pragma mark - Table View data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + self.game.numberOfSaveStates;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"row"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedrow"]];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]];
    
    // text
    cell.textLabel.text = @"Start Game";
    cell.detailTextLabel.text = @"new game";
    
    // detail
    if (indexPath.row > 0) {
        cell.textLabel.text = indexPath.row == 1 ? @"Resume Game" : [self.game nameOfSaveStateAtIndex:indexPath.row - 1];
        cell.detailTextLabel.text = [[self.game dateOfSaveStateAtIndex:indexPath.row -1] descriptionWithLocale:[NSLocale currentLocale]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.game deleteSaveStateAtIndex:indexPath.row - 1]) [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if (self.game.numberOfSaveStates == 0) [(SASlideMenuRootViewController*)self.parentViewController doSlideIn:nil];
    }
}

#pragma mark - Table View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AppDelegate.sharedInstance startGame:self.game withSavedState:indexPath.row - 1];
}

@end

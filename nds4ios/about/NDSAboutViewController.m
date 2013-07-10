//
//  NDSAboutViewController.m
//  nds4ios
//
//  Created by Developer on 7/8/13.
//  Copyright (c) 2013 DS Team. All rights reserved.
//

#import "NDSAboutViewController.h"

@interface NDSAboutViewController ()

@end

@implementation NDSAboutViewController

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=angelXwind"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=angelXwind"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/angelXwind"]];
    }
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=iPlop"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=iPlop"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/iPlop"]];
    }
    if (indexPath.section == 0 && indexPath.row == 2)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=maczydeco"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=maczydeco"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/maczydeco"]];
    }
    if (indexPath.section == 0 && indexPath.row == 3)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=rileytestut"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=rileytestut"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/rileytestut"]];
    }
    if (indexPath.section == 0 && indexPath.row == 4)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=dchavezlive"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=dchavezlive"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/dchavezlive"]];
    }
    if (indexPath.section == 0 && indexPath.row == 5)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=Malvix_"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=Malvix_"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/Malvix_"]];
    }
    if (indexPath.section == 0 && indexPath.row == 6)
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=wj82315"]])
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=wj82315"]];
        else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/wj82315"]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

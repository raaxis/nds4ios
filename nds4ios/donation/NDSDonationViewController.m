//
//  NDSDonationViewController.m
//  nds4ios
//
//  Created by Developer on 7/10/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSDonationViewController.h"

@interface NDSDonationViewController ()

@end

@implementation NDSDonationViewController

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

    donateTitle.title = NSLocalizedString(@"Donate", nil);
    donateLabel.text = NSLocalizedString(@"Donate using PayPal", nil);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView  titleForFooterInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"We all work hard to make this into software that users will enjoy and love. If you enjoy this software, please consider making a donation to help us create and provide better things.", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MCAFUKL3CM8QQ"]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

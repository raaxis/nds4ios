//
//  NDSRightMenuViewController.h
//  nds4ios
//
//  Created by David Chavez on 7/15/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASlideMenuRootViewController.h"
#import "NDSGame.h"

@interface NDSRightMenuViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NDSGame *game;

@end

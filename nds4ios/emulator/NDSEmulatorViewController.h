//
//  NDSEmulatorViewController.h
//  nds4ios
//
//  Created by InfiniDev on 6/11/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDSDirectionalControl.h"
#import "NDSButtonControl.h"

@interface NDSEmulatorViewController : UIViewController <UIActionSheetDelegate>

@property (copy, nonatomic) NSString *romFilepath;

- (void)pauseEmulation;
- (void)resumeEmulation;

@end

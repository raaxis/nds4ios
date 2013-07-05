//
//  ButtonControl.h
//  nds4ios
//
//  Created by InfiniDev on 7/5/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSDirectionalControl.h"

// This class really doesn't do much. It's basically here to make the code easier to read, but also in case of future expansion.

// Below are identical to the superclass variants, just renamed for clarity
typedef NS_ENUM(NSInteger, NDSButtonControlButton) {
    NDSButtonControlButtonX     = 1 << 0,
    NDSButtonControlButtonB     = 1 << 1,
    NDSButtonControlButtonY     = 1 << 2,
    NDSButtonControlButtonA     = 1 << 3,
};

@interface NDSButtonControl : NDSDirectionalControl

@property (readonly, nonatomic) NDSButtonControlButton selectedButtons;

@end

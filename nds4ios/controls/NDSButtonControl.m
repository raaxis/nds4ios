//
//  ButtonControl.m
//  nds4ios
//
//  Created by Riley Testut on 7/5/13.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import "NDSButtonControl.h"

@interface NDSDirectionalControl ()

@property (strong, nonatomic) UIImageView *backgroundImageView;

@end

@interface NDSButtonControl ()

@property (readwrite, nonatomic) NDSButtonControlButton selectedButtons;

@end

@implementation NDSButtonControl

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        self.backgroundImageView.image = [UIImage imageNamed:@"ABXYPad"];
    }
    return self;
}

- (NDSButtonControlButton)selectedButtons {
    return (NDSButtonControlButton)self.direction;
}

@end

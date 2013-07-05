//
//  NDSDirectionalControl.h
//  nds4ios
//
//  Created by InfiniDev on 7/4/2013.
//  Copyright (c) 2013 InfiniDev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NDSDirectionalControlDirection) {
    NDSDirectionalControlDirectionUp     = 1 << 0,
    NDSDirectionalControlDirectionDown   = 1 << 1,
    NDSDirectionalControlDirectionLeft   = 1 << 2,
    NDSDirectionalControlDirectionRight  = 1 << 3,
};

typedef NS_ENUM(NSInteger, NDSDirectionalControlStyle) {
    NDSDirectionalControlStyleDPad = 0,
    NDSDirectionalControlStyleJoystick = 1,
};

@interface NDSDirectionalControl : UIControl

@property (readonly, nonatomic) NDSDirectionalControlDirection direction;
@property (assign, nonatomic) NDSDirectionalControlStyle style;

@end

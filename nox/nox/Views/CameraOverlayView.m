//
//  CameraOverlayView.m
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //Set Camera View Background Color
    [[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0] setFill];
    UIRectFill(rect);
    
    //Make photo area transparent
    CGRect photoRect = CGRectMake(10, 60, 300, 300);
    [[UIColor clearColor] setFill];
    UIRectFill(photoRect);
}


@end

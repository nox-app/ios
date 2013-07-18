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
    [[UIColor colorWithRed:64.0/255.0 green:103.0/255.0 blue:158.0/255.0 alpha:0.8] setFill];
    UIRectFill(rect);
    
    //Make photo area transparent
    CGRect photoRect = CGRectMake(10, 60, 300, 300);
    [[UIColor clearColor] setFill];
    UIRectFill(photoRect);
}


@end

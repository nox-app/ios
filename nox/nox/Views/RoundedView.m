//
//  RoundedView.m
//  nox
//
//  Created by Justine DiPrete on 7/18/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "RoundedView.h"

static const double kViewCornerRadius = 10.0;
static const double kBorderWidth = 5.0;

@implementation RoundedView

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //set the view frame
    CGRect activeBounds = self.bounds;
    CGFloat cornerRadius = kViewCornerRadius;
    CGFloat inset = 5.0f;
    CGFloat originX = activeBounds.origin.x + inset;
    CGFloat originY = activeBounds.origin.y + inset;
    CGFloat width = activeBounds.size.width - (inset*2.0f);
    CGFloat height = activeBounds.size.height - (inset*2.0f);
    
    CGRect bPathFrame = CGRectMake(originX, originY, width, height);
    CGPathRef path;
    if([[UIBezierPath class] respondsToSelector:@selector(bezierPathWithRoundedRect:cornerRadius:)])
    {
        path = [UIBezierPath bezierPathWithRoundedRect:bPathFrame cornerRadius:cornerRadius].CGPath;
    }
    else
    {
        path = CGPathCreateWithRect(bPathFrame, NULL);
    }
    
    //Add a border
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, kBorderWidth);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0f].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 4.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    
    //Add a background color
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(2.0f, 4.0f), 8.0f, [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
}

@end

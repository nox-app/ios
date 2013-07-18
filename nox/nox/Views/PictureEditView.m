//
//  PictureEditView.m
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "PictureEditView.h"

static const float kImageDimension = 300.0;
static const float kImageXOffset = 10.0;
static const float kImageYOffset = 35.0;

static const double kViewCornerRadius = 10.0;
static const double kBorderWidth = 5.0;

@implementation PictureEditView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        //m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageXOffset, kImageYOffset, kImageDimension, kImageDimension)];
    }
    return self;
}

- (void)setImage:(UIImage *)a_image
{
    m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kImageXOffset, kImageYOffset, kImageDimension, kImageDimension)];
    m_image = a_image;
    [m_imageView setImage:m_image];
    [self addSubview:m_imageView];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
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
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0f].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 4.0f, [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathStroke);
    
    //Add a background color
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(2.0f, 4.0f), 8.0f, [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0f].CGColor);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
}


@end

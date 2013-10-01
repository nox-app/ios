//
//  Util.m
//  nox
//
//  Created by Justine DiPrete on 8/22/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *)stringFromDate:(NSDate *)a_date
{
    int second = 1;
    int minute = 60 * second;
    int hour = 60 * minute;
    int day = 24 * hour;
    int year = 365 * day;
    
    NSTimeInterval timePassed = -[a_date timeIntervalSinceNow];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];
    
    if(timePassed < 0)
    {
        [formatter setDateFormat:@"MMMM dd' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }
    
    if(timePassed < 1 * minute)
    {
        return timePassed == 1 ? @"a second ago" : [NSString stringWithFormat:@"%d seconds ago", (int)timePassed];
    }
    
    if(timePassed < 60 * minute)
    {
        int minutes = timePassed/minute;
        return minutes == 1 ? @"a minute ago" : [NSString stringWithFormat:@"%d minutes ago", minutes];
    }

    if(timePassed < 24 * hour)
    {
        int hours = timePassed/hour;
        return hours == 1 ? @"an hour ago" : [NSString stringWithFormat:@"%d hours ago", hours];
    }
    
    if(timePassed < day * 7)
    {
        [formatter setDateFormat:@"cccc' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }
    
    if(timePassed > (24 * hour) && timePassed < year)
    {
        [formatter setDateFormat:@"MMMM dd' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }
    else
    {
        [formatter setDateFormat:@"MMMM dd', 'YYYY' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }

}

//scale these down to save memory cause shit is crashing...
+ (UIImage *)resizeImage:(UIImage *)a_image toSize:(CGSize)a_size
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, a_size.width, a_size.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = a_image.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    BOOL transpose;
    switch(a_image.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transpose = YES;
            break;
            
        default:
            transpose = NO;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (a_image.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, a_size.width, a_size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, a_size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, a_size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (a_image.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, a_size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, a_size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
    
}

@end

//
//  Util.h
//  nox
//
//  Created by Justine DiPrete on 8/22/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString *)stringFromDate:(NSDate *)a_date;
+ (UIImage *)resizeImage:(UIImage *)a_image toSize:(CGSize)a_size;

@end

//
//  Post.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface Post : NSObject
{
    NSInteger m_id;
    NSDate * m_time;
    
    CLLocation * m_location;
}

@property NSInteger id;
@property NSDate * time;
@property CLLocation * location;

@end

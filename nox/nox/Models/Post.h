//
//  Post.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class User;

typedef enum PostType
{
    kImageType = 0,
    kTextType,
    kPlaceType
} PostType;

@interface Post : NSObject
{
    NSInteger m_id;
    NSDate * m_time;
    CLLocation * m_location;
    
    User * m_user;
    
    PostType m_type;
}

@property NSInteger id;
@property NSDate * time;
@property CLLocation * location;
@property User * user;
@property PostType type;

@end

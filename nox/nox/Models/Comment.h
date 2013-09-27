//
//  Comment.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class User;

@interface Comment : NSObject
{
    NSInteger m_id;
    NSDate * m_time;
    CLLocation * m_location;
    
    NSString * m_body;
    
    NSString * m_resourceURI;
    
    NSString * m_postURI;
    
    User * m_user;
}

@property NSInteger id;
@property NSDate * time;
@property CLLocation * location;
@property User * user;
@property NSString * body;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

@end

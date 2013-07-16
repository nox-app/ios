//
//  Profile.h
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class User;

@interface Profile : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate>
{
    User * m_user;
    NSMutableArray * m_events;
    
    NSMutableData * m_downloadBuffer;
    
    CLLocationManager * m_locationManager;
    
    CLLocation * m_lastLocation;
}

@property (readonly) NSMutableArray * events;
@property (nonatomic) User * user;
@property CLLocation * lastLocation;

+ (Profile *)sharedProfile;

@end

//
//  Profile.h
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"

@class Event;
@class User;

typedef enum RequestTag
{
    kRequestDownloadEventsTag = 1,
    kRequestAddEventTag,
    kRequestUpdateEventTag,
    kRequestDeleteEventTag
} RequestTag;

@interface Profile : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate>
{
    User * m_user;
    NSString * m_apiKey;
    NSMutableArray * m_events;
    
    NSMutableData * m_downloadBuffer;
    
    CLLocationManager * m_locationManager;
    
    CLLocation * m_lastLocation;
}

@property (readonly) NSMutableArray * events;
@property (nonatomic) User * user;
@property CLLocation * lastLocation;
@property NSString * apiKey;

+ (Profile *)sharedProfile;

- (void)addEvent:(Event *)a_event;
- (void)updateEvent:(Event *)a_event;
- (void)downloadEvents;
- (void)deleteEvent:(Event *)a_event;

@end

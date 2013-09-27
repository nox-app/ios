//
//  Profile.h
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "ASIHTTPRequestDelegate.h"

extern NSString * const kContactFilterDidFinishNotification;

@class Event;
@class User;

typedef enum RequestTag
{
    kRequestDownloadEventsTag = 1,
    kRequestAddEventTag,
    kRequestUpdateEventTag,
    kRequestDeleteEventTag,
    kRequestUserSearchTag
} RequestTag;

@interface Profile : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate>
{
    User * m_user;
    NSString * m_apiKey;
    NSMutableArray * m_events;
    
    NSMutableData * m_downloadEventsBuffer;
    NSMutableData * m_downloadUsersBuffer;
    NSMutableData * m_downloadAddEventBuffer;
    
    CLLocationManager * m_locationManager;
    
    CLLocation * m_lastLocation;
    
    NSMutableArray * m_contacts;
    
    NSMutableArray * m_userFriends;
    
    NSString * m_currentCity;
}

@property (readonly) NSMutableArray * events;
@property (nonatomic) User * user;
@property CLLocation * lastLocation;
@property NSString * apiKey;
@property NSMutableArray * contacts;
@property NSMutableArray * userFriends;
@property NSString * currentCity;

+ (Profile *)sharedProfile;

- (void)addEvent:(Event *)a_event;
- (void)updateEvent:(Event *)a_event;
- (void)downloadEvents;
- (void)deleteEvent:(Event *)a_event;

- (void)logout;

- (User *)userFriendWithResourceURI:(NSString *)a_resourceURI;

@end

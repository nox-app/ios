//
//  Profile.m
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Profile.h"

#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "Event.h"
#import "JSONKit.h"
#import "User.h"

static Profile * g_sharedProfile;

static NSString * const kEventKey = @"eventKey";

@implementation Profile

@synthesize events = m_events;
@synthesize user = m_user;
@synthesize lastLocation = m_lastLocation;
@synthesize apiKey = m_apiKey;

+ (Profile *)sharedProfile
{
    if(g_sharedProfile == nil)
    {
        g_sharedProfile = [[Profile alloc] init];
    }
    return g_sharedProfile;
}

- (id)init
{
    if(self = [super init])
    {
        m_events = [[NSMutableArray alloc] init];
        m_locationManager = [[CLLocationManager alloc] init];
        [m_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [m_locationManager setDistanceFilter:kCLDistanceFilterNone];
        [m_locationManager setPausesLocationUpdatesAutomatically:YES];
        [m_locationManager setDelegate:self];
        [m_locationManager startUpdatingLocation];
        
        if(&UIApplicationDidEnterBackgroundNotification != nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    }
    return self;
}

- (void)setUser:(User *)a_user
{
    m_user = a_user;
    
    [self downloadEvents];
}

#pragma mark - Event methods

- (void)downloadEvents
{
    //download events for the user
    NSString * eventURLString = [kAPIBase stringByAppendingString:kAPIEvents];
    NSURL * eventsURL = [NSURL URLWithString:eventURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventsURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setDelegate:self];
    [request setTag:kRequestDownloadEventsTag];
    [request startAsynchronous];

}

- (void)addEvent:(Event *)a_event
{
    [m_events addObject:a_event];
    
    NSLog(@"Adding event named: %@", [a_event name]);
    NSString * eventURLString = [kAPIBase stringByAppendingString:kAPIEvents];
    NSURL * eventsURL = [NSURL URLWithString:eventURLString];
    
    NSMutableDictionary * eventDictionary = [NSMutableDictionary dictionary];
    [eventDictionary setValue:[a_event name] forKey:@"name"];
    NSString * eventJSON = [eventDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventsURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[eventJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestAddEventTag];
    [request setUserInfo:[NSDictionary dictionaryWithObject:a_event forKey:kEventKey]];
    [request startAsynchronous];
    
}

- (void)updateEvent:(Event *)a_event
{
    NSString * eventURLString = [[kAPIBase stringByAppendingString:kAPIEvents] stringByAppendingString:[NSString stringWithFormat:@"%d/", [a_event id]]];
    NSURL * eventURL = [NSURL URLWithString:eventURLString];
    
    NSMutableDictionary * eventDictionary = [NSMutableDictionary dictionary];
    [eventDictionary setValue:[a_event name] forKey:@"name"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [eventDictionary setValue:[formatter stringFromDate:[a_event endedAt]] forKey:@"ended_at"];
    
    NSString * eventJSON = [eventDictionary JSONString];
    NSLog(@"UPDATE JSON: %@", eventJSON);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setRequestMethod:@"PUT"];
    [request appendPostData:[eventJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestUpdateEventTag];
    [request startAsynchronous];
}

- (void)deleteEvent:(Event *)a_event
{
    [m_events removeObject:a_event];
    
    NSString * eventURLString = [[kAPIBase stringByAppendingString:kAPIEvents] stringByAppendingString:[NSString stringWithFormat:@"%d/", [a_event id]]];
    NSURL * eventURL = [NSURL URLWithString:eventURLString];
    
    NSLog(@"Event URL to delete: %@", eventURL);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setRequestMethod:@"DELETE"];
    [request setDelegate:self];
    [request setTag:kRequestDeleteEventTag];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    int statusCode = [request responseStatusCode];
    NSLog(@"Status is: %d", statusCode);
    
    //@todo(jdiprete): get content length and init with capacity?
    m_downloadBuffer = nil;
    m_downloadBuffer = [[NSMutableData alloc] init];
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    [m_downloadBuffer appendData:a_data];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    if([request tag] == kRequestDownloadEventsTag)
    {
        if(m_downloadBuffer)
        {
            NSDictionary * events = [[decoder objectWithData:m_downloadBuffer] objectForKey:@"objects"];
            m_downloadBuffer = nil;
            
            NSLog(@"EVENTS: %@", events);
            if(events)
            {
                [m_events removeAllObjects];
                
                for(NSDictionary * event in events)
                {
                    Event * newEvent = [[Event alloc] initWithDictionary:event];
                    [m_events addObject:newEvent];
                    
                    //@todo(jdiprete):this is gonna a lottt of data, change so you just download the image thumbnails
                    [newEvent downloadPosts];
                }
                //sort the array by time - is this necessary? Maybe just read from the array backwards...
                //or sort some other way?
                m_events = [NSMutableArray arrayWithArray:[m_events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Event *)a startedAt];
                    NSDate * second = [(Event *)b startedAt];
                    return [second compare:first];
                }]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kEventsDownloadFinishedNotification object:self];
        }
    }
    else if([request tag] == kRequestAddEventTag)
    {
        if(m_downloadBuffer)
        {
            Event * event = [[request userInfo] objectForKey:kEventKey];
            NSDictionary * eventDictionary = [decoder objectWithData:m_downloadBuffer];
            m_downloadBuffer = nil;
            if(eventDictionary)
            {
                [event updateWithDictionary:eventDictionary];
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreationSucceededNotification object:event];
            }
            //@todo(jdiprete): post notification for success or failure
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed with Error: %@", [request error]);
    if([request tag] == kRequestAddEventTag)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreationFailedNotification object:nil];
    }
    m_downloadBuffer = nil;
}

#pragma mark - Location Methods

- (void)didEnterBackground
{
    [m_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    m_lastLocation = newLocation;
}

@end

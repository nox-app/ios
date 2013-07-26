//
//  Profile.m
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Profile.h"

#import "Constants.h"
#import "Event.h"
#import "JSONKit.h"
#import "User.h"

static Profile * g_sharedProfile;

@implementation Profile

@synthesize events = m_events;
@synthesize user = m_user;
@synthesize lastLocation = m_lastLocation;

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

- (void)downloadEvents
{
    //download events for the user
    NSURL * eventsURL = [NSURL URLWithString:kEventsURL];
    NSURLRequest * request = [NSURLRequest requestWithURL:eventsURL];
    NSURLConnection * connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
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

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)a_connection didReceiveResponse:(NSURLResponse *)a_response
{
    if([a_response expectedContentLength] == NSURLResponseUnknownLength)
    {
        m_downloadBuffer = [[NSMutableData alloc] init];
    }
    else
    {
        m_downloadBuffer = [[NSMutableData alloc] initWithCapacity:[a_response expectedContentLength]];
    }
}

- (void)connection:(NSURLConnection *)a_connection didReceiveData:(NSData *)a_data
{
    [m_downloadBuffer appendData:a_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)a_connection
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    NSDictionary * response = [[decoder objectWithData:m_downloadBuffer] objectForKey:@"response"];
    if(response)
    {
        NSDictionary * events = [response objectForKey:@"events"];
        if(events)
        {
            [m_events removeAllObjects];
            
            for(NSDictionary * event in events)
            {
                Event * newEvent = [[Event alloc] initWithDictionary:event];
                [self addEvent:newEvent];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventsDownloadFinishedNotification object:self];
}

- (void)connection:(NSURLConnection *)a_connection didFailWithError:(NSError *)a_error
{
    m_downloadBuffer = nil;
}

- (void)addEvent:(Event *)a_event
{
    [m_events addObject:a_event];
    
    //sort the array by time - is this necessary? Maybe just read from the array backwards...
    //or sort some other way?
    m_events = [NSMutableArray arrayWithArray:[m_events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate * first = [(Event *)a startedAt];
        NSDate * second = [(Event *)b startedAt];
        return [second compare:first];
    }]];
}

@end

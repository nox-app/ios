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
#import "Contact.h"
#import "Event.h"
#import "JSONKit.h"
#import "User.h"

static Profile * g_sharedProfile;

static NSString * const kEventKey = @"eventKey";

NSString * const kContactFilterDidFinishNotification = @"ContactFilterDidFinishNotification";

@implementation Profile

@synthesize events = m_events;
@synthesize user = m_user;
@synthesize lastLocation = m_lastLocation;
@synthesize apiKey = m_apiKey;
@synthesize contacts = m_contacts;
@synthesize userFriends = m_userFriends;
@synthesize currentCity = m_currentCity;

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
        
        m_contacts = [[NSMutableArray alloc] init];
        m_userFriends = [[NSMutableArray alloc] init];
        
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
    
    [self importContacts];
    [self sendContactsToServer];
    [self downloadEvents];
}

- (User *)userFriendWithResourceURI:(NSString *)a_resourceURI;
{
    for(User * user in m_userFriends)
    {
        if([a_resourceURI isEqualToString:[user resourceURI]])
        {
            return user;
        }
    }
    return nil;
}

#pragma mark - Contact Methods

- (void)importContacts
{
    [m_contacts removeAllObjects];

    if(ABAddressBookRequestAccessWithCompletion != NULL) //iOS 6+
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
             {
                 [self addContactsFromAddressBook:addressBook];
             });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            [self addContactsFromAddressBook:addressBook];
        }
    }
    else //iOS < 6
    {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        [self addContactsFromAddressBook:addressBook];
    }
    
}

- (void)addContactsFromAddressBook:(ABAddressBookRef)addressBook
{
    CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    CFIndex count = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableSet * linkedContacts = [[NSMutableSet alloc] init];
    
    for(int i = 0; i < count; i++)
    {
        ABRecordRef contactRef = CFArrayGetValueAtIndex(contacts, i);
        
        if([linkedContacts containsObject:(__bridge id)(contactRef)])
        {
            continue;
        }
        
        Contact * contact = [[Contact alloc] initWithContactRef:contactRef];
        
        NSArray * linked = (__bridge NSArray *)ABPersonCopyArrayOfAllLinkedPeople(contactRef);
        if([linked count] > 1)
        {
            [linkedContacts addObjectsFromArray:linked];
            for(int j = 0; j < [linked count]; j++)
            {
                ABRecordRef linkedPerson = (__bridge ABRecordRef)([linked objectAtIndex:j]);
                if(linkedPerson == contactRef)
                {
                    continue;
                }
                [contact mergeInfoFromContactRef:linkedPerson];
            }
        }
        [m_contacts addObject:contact];
    }
}

- (void)sendContactsToServer
{
    NSMutableArray * contacts = [[NSMutableArray alloc] init];
    for(Contact * contact in m_contacts)
    {
        NSMutableDictionary * contactDictionary = [[NSMutableDictionary alloc] init];
        if([contact phoneNumbers] && [[contact phoneNumbers] count] > 0)
        {
            [contactDictionary setValue:[contact phoneNumbers] forKey:@"phone_numbers"];
        }
        if([contact emails] && [[contact emails] count] > 0)
        {
            [contactDictionary setValue:[contact emails] forKey:@"emails"];
        }
        
        [contacts addObject:contactDictionary];
    }
    NSString * contactJSON = [contacts JSONString];
    
    NSString * userSearchURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPISearchUsers]];
    NSURL * userSearchURL = [NSURL URLWithString:userSearchURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:userSearchURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[contactJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestUserSearchTag];
    [request startAsynchronous];
    
}

- (void)filterContacts
{
    for(User * user in m_userFriends)
    {
        for(Contact * contact in m_contacts)
        {
            if([[contact emails] containsObject:[user email]] || [[contact phoneNumbers] containsObject:[user phoneNumber]])
            {
                [m_contacts removeObject:contact];
                break;
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactFilterDidFinishNotification object:nil];
}

#pragma mark - Event methods

- (void)downloadEvents
{
    //download events for the user
    NSLog(@"DOWNLOADING EVENTS!!");
    NSString * eventURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIEvents]];
    NSURL * eventsURL = [NSURL URLWithString:eventURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventsURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setDelegate:self];
    [request setTag:kRequestDownloadEventsTag];
    [request startAsynchronous];

}

- (void)addEvent:(Event *)a_event
{
    [m_events addObject:a_event];
    
    NSLog(@"Adding event named: %@", [a_event name]);
    NSString * eventURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIEvents]];
    NSURL * eventsURL = [NSURL URLWithString:eventURLString];
    
    NSMutableDictionary * eventDictionary = [NSMutableDictionary dictionary];
    [eventDictionary setValue:[a_event name] forKey:@"name"];
    NSString * eventJSON = [eventDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventsURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[eventJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestAddEventTag];
    [request setUserInfo:[NSDictionary dictionaryWithObject:a_event forKey:kEventKey]];
    [request startAsynchronous];
    
}

- (void)updateEvent:(Event *)a_event
{
    NSString * eventURLString = [kNoxBase stringByAppendingString:[[kAPIBase stringByAppendingString:kAPIEvents] stringByAppendingString:[NSString stringWithFormat:@"%d/", [a_event id]]]];
    NSURL * eventURL = [NSURL URLWithString:eventURLString];
    
    NSMutableDictionary * eventDictionary = [NSMutableDictionary dictionary];
    [eventDictionary setValue:[a_event name] forKey:@"name"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [eventDictionary setValue:[formatter stringFromDate:[a_event endedAt]] forKey:@"ended_at"];
    [eventDictionary setValue:[formatter stringFromDate:[a_event startedAt]] forKey:@"created_at"];
    
    NSString * eventJSON = [eventDictionary JSONString];
    NSLog(@"UPDATE JSON: %@", eventJSON);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"PUT"];
    [request appendPostData:[eventJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestUpdateEventTag];
    [request startAsynchronous];
}

- (void)deleteEvent:(Event *)a_event
{
    [m_events removeObject:a_event];
    
    NSString * eventURLString = [kNoxBase stringByAppendingString:[[kAPIBase stringByAppendingString:kAPIEvents] stringByAppendingString:[NSString stringWithFormat:@"%d/", [a_event id]]]];
    NSURL * eventURL = [NSURL URLWithString:eventURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
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
    
    switch([request tag])
    {
        case kRequestDownloadEventsTag:
            m_downloadEventsBuffer = nil;
            m_downloadEventsBuffer = [[NSMutableData alloc] init];
            break;
        case kRequestAddEventTag:
            m_downloadAddEventBuffer = nil;
            m_downloadAddEventBuffer = [[NSMutableData alloc] init];
        case kRequestUserSearchTag:
            m_downloadUsersBuffer = nil;
            m_downloadUsersBuffer = [[NSMutableData alloc] init];
        default:
            break;
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    switch([request tag])
    {
        case kRequestDownloadEventsTag:
            [m_downloadEventsBuffer appendData:a_data];
            break;
        case kRequestAddEventTag:
            [m_downloadAddEventBuffer appendData:a_data];
        case kRequestUserSearchTag:
            [m_downloadUsersBuffer appendData:a_data];
        default:
            break;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    if([request tag] == kRequestDownloadEventsTag)
    {
        if(m_downloadEventsBuffer)
        {
            NSLog(@"REQUEST FINISHED: %@", [[request url] absoluteString]);
            NSLog(@"RESPONSE: %@", [decoder objectWithData:m_downloadEventsBuffer]);
            NSDictionary * events = [[decoder objectWithData:m_downloadEventsBuffer] objectForKey:@"objects"];
            m_downloadEventsBuffer = nil;
            if(events)
            {
                [m_events removeAllObjects];
                
                for(NSDictionary * event in events)
                {
                    NSLog(@"REQUEST: %@", [[request url] absoluteString]);
                    NSLog(@"EVENT: %@", event);
                    Event * newEvent = [[Event alloc] initWithDictionary:event];
                    [m_events addObject:newEvent];

                    [newEvent downloadImagePosts];
                    [newEvent downloadEventMembers];
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
        if(m_downloadAddEventBuffer)
        {
            Event * event = [[request userInfo] objectForKey:kEventKey];
            NSDictionary * eventDictionary = [decoder objectWithData:m_downloadAddEventBuffer];
            m_downloadAddEventBuffer = nil;
            if(eventDictionary)
            {
                [event updateWithDictionary:eventDictionary];
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventCreationSucceededNotification object:event];
            }
            m_events = [NSMutableArray arrayWithArray:[m_events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSDate * first = [(Event *)a startedAt];
                NSDate * second = [(Event *)b startedAt];
                return [second compare:first];
            }]];
            //@todo(jdiprete): post notification for success or failure
        }
    }
    else if([request tag] == kRequestUserSearchTag)
    {
        if(m_downloadUsersBuffer)
        {
            [m_userFriends removeAllObjects];
            NSArray * userArray = [decoder objectWithData:m_downloadUsersBuffer];
            NSLog(@"REQUEST: %@", [[request url] absoluteString]);
            NSLog(@"USER ARRAY: %@", userArray);
            for(NSDictionary * userDictionary in userArray)
            {
                NSLog(@"USER DICTIONARY: %@", userDictionary);
                User * user = [[User alloc] initWithDictionary:userDictionary];
                [m_userFriends addObject:user];
            }
            [self filterContacts];
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
    switch([request tag])
    {
        case kRequestDownloadEventsTag:
            m_downloadEventsBuffer = nil;
            break;
        case kRequestAddEventTag:
            m_downloadAddEventBuffer = nil;
        case kRequestUserSearchTag:
            m_downloadUsersBuffer = nil;
        default:
            break;
    }
}

#pragma mark - Location Methods

- (void)didEnterBackground
{
    [m_locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    m_lastLocation = newLocation;
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:m_lastLocation completionHandler:^(NSArray * placemarks, NSError * error)
    {
        if(error)
        {
            return;
        }
        else
        {
            if(placemarks && [placemarks count] > 0)
            {
                CLPlacemark * placemark = [placemarks objectAtIndex:0];
                NSDictionary * addressDictionary = [placemark addressDictionary];
                NSString * city = [addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
                NSString * state = [addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
                m_currentCity = [NSString stringWithFormat:@"%@, %@", city, state];
            }
        }
    }];
}

- (void)logout
{
    m_user = nil;
    [m_events removeAllObjects];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

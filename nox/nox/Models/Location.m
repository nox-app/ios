//
//  Location.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize address = m_address;
@synthesize country = m_country;
@synthesize countryCode = m_countryCode;
@synthesize city = m_city;
@synthesize postalCode = m_postalCode;
@synthesize state = m_state;
@synthesize crossStreet = m_crossStreet;
@synthesize distance = m_distance;
@synthesize coordinate = m_coordinate;

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super init])
    {
        [self setPropertiesFromDictionary:a_dictionary];
    }
    return self;
}

- (void)setPropertiesFromDictionary:(NSDictionary *)a_dictionary
{
    m_address = [a_dictionary objectForKey:@"address"];
    m_country = [a_dictionary objectForKey:@"country"];
    m_countryCode = [a_dictionary objectForKey:@"cc"];
    m_city = [a_dictionary objectForKey:@"city"];
    m_postalCode = [a_dictionary objectForKey:@"postalCode"];
    m_state = [a_dictionary objectForKey:@"state"];
    m_crossStreet = [a_dictionary objectForKey:@"crossStreet"];
    m_distance = [[a_dictionary objectForKey:@"distance"] intValue];
    float latitude = [[a_dictionary objectForKey:@"lat"] floatValue];
    float longitude = [[a_dictionary objectForKey:@"lng"] floatValue];
    m_coordinate = CLLocationCoordinate2DMake(latitude, longitude);
}

@end

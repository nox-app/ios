//
//  Venue.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Venue.h"

#import "Location.h"

@implementation Venue
@synthesize iconURL = m_iconURL;
@synthesize iconImage = m_iconImage;
@synthesize id = m_id;
@synthesize name = m_name;
@synthesize phoneNumber = m_phoneNumber;
@synthesize URL = m_URL;
@synthesize location = m_location;

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
    NSArray * categories = [a_dictionary objectForKey:@"categories"];
    if([categories count] > 0)
    {
        //only do the first for now...
        NSDictionary * category = [categories objectAtIndex:0];
        NSDictionary * icon = [category objectForKey:@"icon"];
        NSString * prefix = [icon objectForKey:@"prefix"];
        prefix = [prefix substringToIndex:[prefix length] - 1];
        m_iconURL = [prefix stringByAppendingString:[icon objectForKey:@"suffix"]];
        [self performSelectorInBackground:@selector(downloadIcon) withObject:nil];
    }
    
    m_id = [a_dictionary objectForKey:@"id"];
    m_name = [a_dictionary objectForKey:@"name"];
    m_URL = [a_dictionary objectForKey:@"canonicalUrl"];
    
    NSDictionary * contact = [a_dictionary objectForKey:@"contact"];
    m_phoneNumber = [contact objectForKey:@"phone"];
    
    NSDictionary * locationDictionary = [a_dictionary objectForKey:@"location"];
    m_location = [[Location alloc] initWithDictionary:locationDictionary];
    
}

- (void)downloadIcon
{
    m_iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:m_iconURL]]];
}


@end
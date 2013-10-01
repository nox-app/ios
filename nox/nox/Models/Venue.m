//
//  Venue.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Venue.h"

#import "Location.h"

NSString * const kVenueIconDidDownloadNotification = @"VenueIconDidDownloadNotification";

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
        m_iconURL = [[prefix stringByAppendingString:@"88"] stringByAppendingString:[icon objectForKey:@"suffix"]];
        [self performSelectorInBackground:@selector(downloadIcon) withObject:nil];
    }
    else
    {
        m_iconImage = [UIImage imageNamed:@"defaultvenue.png"];
    }
    
    m_id = [a_dictionary objectForKey:@"id"];
    m_name = [a_dictionary objectForKey:@"name"];
    m_URL = [a_dictionary objectForKey:@"canonicalUrl"];
    
    NSDictionary * contact = [a_dictionary objectForKey:@"contact"];
    m_phoneNumber = [contact objectForKey:@"phone"];
    
    NSDictionary * locationDictionary = [a_dictionary objectForKey:@"location"];
    m_location = [[Location alloc] initWithDictionary:locationDictionary];
    
}

- (void)iconDownloadDidFinish
{
    if(!m_iconImage)
    {
        m_iconImage = [UIImage imageNamed:@"defaultvenue.png"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kVenueIconDidDownloadNotification object:self];
}

- (void)downloadIcon
{
    //@todo(jdiprete):Use NSURLConnection so you can cache these
    NSLog(@"ICON: %@", m_iconURL);
    m_iconImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:m_iconURL]]];
    [self performSelectorOnMainThread:@selector(iconDownloadDidFinish) withObject:nil waitUntilDone:NO];
}


@end

//
//  PlacePost.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "PlacePost.h"

#import "Venue.h"

@implementation PlacePost

@synthesize caption = m_caption;
@synthesize venue = m_venue;

- (id)init
{
    if(self = [super init])
    {
        m_type = kPlaceType;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super initWithDictionary:a_dictionary])
    {
        m_type = kPlaceType;
    }
    return self;
}

@end

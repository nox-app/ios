//
//  Post.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Post.h"

#import "NSDictionary+Util.h"

@implementation Post

@synthesize id = m_id;
@synthesize time = m_time;
@synthesize location = m_location;
@synthesize user = m_user;
@synthesize type = m_type;
@synthesize event = m_event;

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super init])
    {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        m_time = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"created_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
        m_id = [[a_dictionary objectForKeyNotNull:@"id"] intValue];
        
        CLLocation * location = [[CLLocation alloc] initWithLatitude:[[a_dictionary objectForKeyNotNull:@"latitude"] doubleValue] longitude:[[a_dictionary objectForKeyNotNull:@"longitude"] doubleValue]];
        m_location = location;
        m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
        m_event = [a_dictionary objectForKeyNotNull:@"event"];
    }
    return self;
}

@end

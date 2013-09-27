//
//  Comment.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Comment.h"

#import "NSDictionary+Util.h"
#import "User.h"

@implementation Comment

@synthesize id = m_id;
@synthesize time = m_time;
@synthesize location = m_location;
@synthesize user = m_user;
@synthesize body = m_body;

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
        m_body = [a_dictionary objectForKeyNotNull:@"body"];
        m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
        m_postURI = [a_dictionary objectForKeyNotNull:@"post"];
        m_user = [[User alloc] initWithDictionary:[a_dictionary objectForKeyNotNull:@"user"]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

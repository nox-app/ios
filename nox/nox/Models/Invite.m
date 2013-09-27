//
//  Invite.m
//  nox
//
//  Created by Justine DiPrete on 9/26/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Invite.h"

#import "NSDictionary+Util.h"
#import "Profile.h"
#import "User.h"

@implementation Invite

@synthesize id = m_id;
@synthesize resourceURI = m_resourceURI;
@synthesize userResourceURI = m_userResourceURI;
@synthesize user = m_user;
@synthesize rsvp = m_rsvp;

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
    m_id = [[a_dictionary objectForKeyNotNull:@"id"] intValue];
    m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
    m_userResourceURI = [a_dictionary objectForKeyNotNull:@"user"];
    m_rsvp = [[a_dictionary objectForKeyNotNull:@"rsvp"] boolValue];
}

- (void)lookupUser
{
    m_user = [[Profile sharedProfile] userFriendWithResourceURI:m_userResourceURI];
    if(m_user == nil)
    {
        m_user = [[User alloc] init];
        [m_user downloadUserWithResourceURI:m_userResourceURI];
    }
}

@end

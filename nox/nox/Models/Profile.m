//
//  Profile.m
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Profile.h"

#import "User.h"

static Profile * g_sharedProfile;

@implementation Profile

@synthesize events = m_events;
@synthesize user = m_user;

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
    }
    return self;
}

- (void)setUser:(User *)a_user
{
    m_user = a_user;
}

@end

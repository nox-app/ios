//
//  TextPost.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "TextPost.h"

#import "NSDictionary+Util.h"

@implementation TextPost

@synthesize body = m_body;

- (id)init
{
    if(self = [super init])
    {
        m_type = kTextType;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super initWithDictionary:a_dictionary])
    {
        m_type = kTextType;
        m_body = [a_dictionary objectForKeyNotNull:@"body"];

    }
    return self;
}

@end

//
//  TextPost.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "TextPost.h"

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

@end

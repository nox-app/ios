//
//  ImagePost.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "ImagePost.h"

@implementation ImagePost

@synthesize caption = m_caption;
@synthesize image = m_image;

- (id)init
{
    if(self = [super init])
    {
        m_type = kImageType;
    }
    return self;
}

@end

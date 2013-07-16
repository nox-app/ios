//
//  PlacePost.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Post.h"

@class Venue;

@interface PlacePost : Post
{
    NSString * m_caption;
    Venue * m_venue;
}

@property NSString * caption;
@property Venue * venue;

@end

//
//  NSDictionary+Util.m
//  nox
//
//  Created by Justine DiPrete on 7/25/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "NSDictionary+Util.h"

@implementation NSDictionary(Util)

- (id)objectForKeyNotNull:(id)key
{
    id object = [self objectForKey:key];
    if (object == [NSNull null])
    {
        return nil;
    }
    else
    {
        return object;
    }
}


@end

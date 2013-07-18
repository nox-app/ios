//
//  Event.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Event.h"

#import "Post.h"

@implementation Event

@synthesize id = m_id;
@synthesize name = m_name;
@synthesize startedAt = m_startedAt;
@synthesize endedAt = m_endedAt;
@synthesize updatedAt = m_updatedAt;
@synthesize assetDir = m_assetDir;
@synthesize posts = m_posts;

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super init])
    {
        [self setPropertiesFromDictionary:a_dictionary];
        m_posts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setPropertiesFromDictionary:(NSDictionary *)a_dictionary
{
    m_id = [[a_dictionary objectForKey:@"id"] intValue];
    m_name = [a_dictionary objectForKey:@"name"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    m_startedAt = [formatter dateFromString:[a_dictionary objectForKey:@"started_at"]];
    m_endedAt = [formatter dateFromString:[a_dictionary objectForKey:@"ended_at"]];
    m_updatedAt = [formatter dateFromString:[a_dictionary objectForKey:@"updated_at"]];
    
    m_assetDir = [a_dictionary objectForKey:@"asset_dir"];
}

- (void)addPost:(Post *)a_post
{
    [m_posts addObject:a_post];
    
    //sort the array by time - is this necessary? Maybe just read from the array backwards...
    m_posts = [NSMutableArray arrayWithArray:[m_posts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate * first = [(Post *)a time];
        NSDate * second = [(Post *)b time];
        return [second compare:first];
    }]];
}

@end

//
//  Event.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;

@interface Event : NSObject
{
    NSInteger m_id;
    NSString * m_name;
    NSDate * m_startedAt;
    NSDate * m_endedAt;
    NSDate * m_updatedAt;
    NSString * m_assetDir;
    
    NSMutableArray * m_posts;
    NSMutableArray * m_images;
}

@property NSInteger id;
@property NSString * name;
@property NSDate * startedAt;
@property NSDate * endedAt;
@property NSDate * updatedAt;
@property NSString * assetDir;

@property NSMutableArray * posts;
@property NSMutableArray * images;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

- (void)addPost:(Post *)a_post;

@end

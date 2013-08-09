//
//  Event.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequestDelegate.h"

@class Post;

extern NSString * const kPostsDidDownloadNotification;
extern NSString * const kEventDidDownloadImageNotification;

typedef enum PostRequestTag
{
    kRequestDownloadPostsTag = 1,
    kRequestAddPostTag
} PostRequestTag;

@interface Event : NSObject <ASIHTTPRequestDelegate>
{
    NSInteger m_id;
    NSString * m_name;
    NSDate * m_startedAt;
    NSDate * m_endedAt;
    NSDate * m_updatedAt;
    NSString * m_resourceURI;
    
    NSMutableArray * m_posts;
    NSMutableArray * m_images;
    
    NSMutableData * m_downloadBuffer;
}

@property NSInteger id;
@property NSString * name;
@property NSDate * startedAt;
@property NSDate * endedAt;
@property NSDate * updatedAt;
@property NSString * resourceURI;

@property NSMutableArray * posts;
@property NSMutableArray * images;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

- (void)updateWithDictionary:(NSDictionary *)a_dictionary;

- (void)addPost:(Post *)a_post;

- (void)downloadPosts;

@end

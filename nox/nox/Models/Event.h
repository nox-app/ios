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
@class User;

extern NSString * const kPostsDidDownloadNotification;
extern NSString * const kEventFinishedImageDownloadsNotification;
extern NSString * const kAddPostDidSucceedNotification;
extern NSString * const kAddPostDidFailNotification;
extern NSString * const kInviteDidSucceedNotification;

typedef enum PostRequestTag
{
    kRequestDownloadPostsTag = 1,
    kRequestDownloadImagePostsTag,
    kRequestDownloadTextPostsTag,
    kRequestDownloadPlacePostsTag,
    kRequestAddPostTag,
    kRequestDownloadMembersTag,
    kRequestInviteUserTag
} PostRequestTag;

@interface Event : NSObject <ASIHTTPRequestDelegate>
{
    NSInteger m_id;
    NSString * m_name;
    NSDate * m_startedAt;
    NSDate * m_endedAt;
    NSDate * m_updatedAt;
    NSString * m_resourceURI;
    User * m_creator;
    
    NSMutableArray * m_posts;
    
    NSMutableArray * m_imagePosts;
    
    NSMutableArray * m_invites;
    
    NSMutableData * m_downloadPostsBuffer;
    NSMutableData * m_downloadImagePostsBuffer;
    NSMutableData * m_downloadTextPostsBuffer;
    NSMutableData * m_downloadPlacePostsBuffer;
    NSMutableData * m_downloadMembersBuffer;
    NSMutableData * m_downloadAddPostBuffer;
    
    int m_imagePostCount;
    BOOL m_imagesAreDownloading;
    BOOL m_postsAreDownloading;
}

@property NSInteger id;
@property NSString * name;
@property NSDate * startedAt;
@property NSDate * endedAt;
@property NSDate * updatedAt;
@property NSString * resourceURI;

@property NSMutableArray * posts;
@property NSMutableArray * imagePosts;
@property BOOL imagesAreDownloading;
@property BOOL postsAreDownloading;
@property NSMutableArray * invites;
@property User * creator;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

- (void)updateWithDictionary:(NSDictionary *)a_dictionary;

- (void)addPost:(Post *)a_post;

- (void)downloadPosts;
- (void)downloadImagePosts;
- (void)downloadPlacePosts;
- (void)downloadTextPosts;

- (void)downloadEventMembers;

- (void)inviteUser:(User *)a_user withRSVP:(BOOL)a_rsvp;

@end

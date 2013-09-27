//
//  Post.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@class Comment;
@class User;

typedef enum PostType
{
    kImageType = 0,
    kTextType,
    kPlaceType
} PostType;

typedef enum CommentRequestTag
{
    kRequestDownloadCommentsTag = 1,
    kRequestAddCommentTag,
    kRequestAddLikeTag,
    kRequestAddDislikeTag
} CommentRequestTag;

typedef enum PostOpinion
{
    kDisliked = -1,
    kNoOpinion = 0,
    kLiked = 1
} PostOpinion;

extern NSString * const kCommentsDidDownloadNotification;
extern NSString * const kCommentAddDidSucceedNotification;
extern NSString * const kCommentAddDidFailNotification;
extern NSString * const kLikeAddDidSucceedNotification;
extern NSString * const kLikeAddDidFailNotification;
extern NSString * const kDislikeAddDidSucceedNotification;
extern NSString * const kDislikeAddDidFailNotification;

@interface Post : NSObject
{
    NSInteger m_id;
    NSDate * m_time;
    CLLocation * m_location;
    
    User * m_user;
    
    PostType m_type;
    NSString * m_resourceURI;
    
    NSString * m_event;
    
    NSMutableArray * m_comments;
    
    NSMutableData * m_downloadBuffer;
    
    int m_commentCount;
    int m_likeCount;
    int m_dislikeCount;
    
    Comment * m_firstComment;
    
    PostOpinion m_opinion;
}

@property NSInteger id;
@property NSDate * time;
@property CLLocation * location;
@property User * user;
@property PostType type;
@property NSString * event;
@property NSArray * comments;
@property int commentCount;
@property int likeCount;
@property int dislikeCount;
@property Comment * firstComment;
@property PostOpinion opinion;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

- (void)updateWithDictionary:(NSDictionary *)a_dictionary;

- (void)downloadComments;

- (void)addComment:(Comment *)a_comment;
- (void)addLike;
- (void)addDislike;
@end

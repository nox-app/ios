//
//  Post.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Post.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Comment.h"
#import "Constants.h"
#import "JSONKit.h"
#import "NSDictionary+Util.h"
#import "Profile.h"
#import "User.h"

NSString * const kCommentsDidDownloadNotification = @"CommentsDidDownloadNotification";
NSString * const kCommentAddDidSucceedNotification = @"CommentAddDidSucceedNotification";
NSString * const kCommentAddDidFailNotification = @"CommentAddDidFailNotification";
NSString * const kLikeAddDidSucceedNotification = @"LikeAddDidSucceedNotification";
NSString * const kLikeAddDidFailNotification = @"LikeAddDidFailNotification";
NSString * const kDislikeAddDidSucceedNotification = @"DislikeAddDidSucceedNotification";
NSString * const kDislikeAddDidFailNotification = @"DislikeAddDidFailNotification";

static NSString * const kCommentKey = @"commentKey";

@implementation Post

@synthesize id = m_id;
@synthesize time = m_time;
@synthesize location = m_location;
@synthesize user = m_user;
@synthesize type = m_type;
@synthesize event = m_event;
@synthesize comments = m_comments;
@synthesize commentCount = m_commentCount;
@synthesize dislikeCount = m_dislikeCount;
@synthesize likeCount = m_likeCount;
@synthesize firstComment = m_firstComment;
@synthesize opinion = m_opinion;

- (id)init
{
    if(self = [super init])
    {
        m_comments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super init])
    {
        [self setPropertiesFromDictionary:a_dictionary];
        m_comments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)a_dictionary
{
    [self setPropertiesFromDictionary:a_dictionary];
}

- (void)setPropertiesFromDictionary:(NSDictionary *)a_dictionary
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    m_time = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"created_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    m_id = [[a_dictionary objectForKeyNotNull:@"id"] intValue];
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:[[a_dictionary objectForKeyNotNull:@"latitude"] doubleValue] longitude:[[a_dictionary objectForKeyNotNull:@"longitude"] doubleValue]];
    m_location = location;
    m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
    m_event = [a_dictionary objectForKeyNotNull:@"event"];
    m_commentCount = [[a_dictionary objectForKeyNotNull:@"comment_count"] intValue];
    m_dislikeCount = [[a_dictionary objectForKeyNotNull:@"dislike_count"] intValue];
    m_likeCount = [[a_dictionary objectForKeyNotNull:@"like_count"] intValue];
    
    m_opinion = [[a_dictionary objectForKeyNotNull:@"opinion"] intValue];
    
    m_user = [[User alloc] initWithDictionary:[a_dictionary objectForKeyNotNull:@"user"]];
    
    //temp until first comment returns the whole comment
    NSDictionary * firstComment = [a_dictionary objectForKeyNotNull:@"first_comment"];
    if(firstComment)
    {
        m_firstComment = [[Comment alloc] initWithDictionary:firstComment];
    }
}

- (void)downloadComments
{
    //download events for the user
    NSString * commentURLString = [kNoxBase stringByAppendingString:[[kAPIBase stringByAppendingString:kAPIComments] stringByAppendingString:[NSString stringWithFormat:@"%@%d", kAPIPostQuery, m_id]]];
    NSURL * commentURL = [NSURL URLWithString:commentURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:commentURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setDelegate:self];
    [request setTag:kRequestDownloadCommentsTag];
    [request startAsynchronous];
}

- (void)addComment:(Comment *)a_comment
{
    NSString * commentURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIComments]];
    NSURL * commentURL = [NSURL URLWithString:commentURLString];
    
    NSMutableDictionary * commentDictionary = [NSMutableDictionary dictionary];
    [commentDictionary setValue:[a_comment body] forKey:@"body"];
    [commentDictionary setValue:[NSNumber numberWithFloat:[a_comment location].coordinate.longitude]  forKey:@"longitutde"];
    [commentDictionary setValue:[NSNumber numberWithFloat:[a_comment location].coordinate.latitude]  forKey:@"latitude"];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [commentDictionary setValue:[formatter stringFromDate:[a_comment time]] forKey:@"created_at"];
    
    //@todo(jdiprete):change this to the resourceURI when that returns the correct thing
    [commentDictionary setValue:[NSString stringWithFormat:@"/api/v1/post/%d/", m_id] forKey:@"post"];
    NSString * commentJSON = [commentDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:commentURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[commentJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request setTag:kRequestAddCommentTag];
    [request setUserInfo:[NSDictionary dictionaryWithObject:a_comment forKey:kCommentKey]];
    [request startAsynchronous];
}

- (void)addLike
{
    NSString * likeURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIPostLike]];
    NSURL * likeURL = [NSURL URLWithString:likeURLString];
    NSDictionary * likeDictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/api/v1/post/%d/", m_id] forKey:@"post"];
    NSString * likeJSON = [likeDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:likeURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[likeJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request setTag:kRequestAddLikeTag];
    [request startAsynchronous];
}

- (void)addDislike
{
    NSString * dislikeURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIPostDislike]];
    NSURL * dislikeURL = [NSURL URLWithString:dislikeURLString];
    NSDictionary * dislikeDictionary = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"/api/v1/post/%d/", m_id] forKey:@"post"];
    NSString * dislikeJSON = [dislikeDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:dislikeURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[dislikeJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setDelegate:self];
    [request setTag:kRequestAddDislikeTag];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    int statusCode = [request responseStatusCode];
    if([request tag] == kRequestAddLikeTag)
    {
        if(statusCode == 201)
        {
            m_likeCount++;
            m_opinion = kLiked;
            [[NSNotificationCenter defaultCenter] postNotificationName:kLikeAddDidSucceedNotification object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLikeAddDidFailNotification object:self];
        }
    }
    else if([request tag] == kRequestAddDislikeTag)
    {
        if(statusCode == 201)
        {
            m_dislikeCount++;
            m_opinion = kDisliked;
            [[NSNotificationCenter defaultCenter] postNotificationName:kDislikeAddDidSucceedNotification object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDislikeAddDidFailNotification object:self];
        }

    }
    NSLog(@"Status is: %d", statusCode);
    
    //@todo(jdiprete): get content length and init with capacity?
    m_downloadBuffer = nil;
    m_downloadBuffer = [[NSMutableData alloc] init];
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    [m_downloadBuffer appendData:a_data];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request tag] == kRequestDownloadCommentsTag)
    {
        JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        
        if(m_downloadBuffer)
        {
            NSDictionary * comments = [[decoder objectWithData:m_downloadBuffer] objectForKey:@"objects"];
            m_downloadBuffer = nil;
            if(comments)
            {
                //@todo(jdiprete): don't delete all the comments every time, just update the existing ones
                [m_comments removeAllObjects];
                
                for(NSDictionary * comment in comments)
                {
                    Comment * newComment = [[Comment alloc] initWithDictionary:comment];
                    [m_comments addObject:newComment];
                }
                //sort the array by time - is this necessary? Maybe just read from the array backwards...
                m_comments = [NSMutableArray arrayWithArray:[m_comments sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Comment *)a time];
                    NSDate * second = [(Comment *)b time];
                    return [first compare:second];
                }]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kCommentsDidDownloadNotification object:self];
        }
    }
    else if([request tag] == kRequestAddCommentTag)
    {
        Comment * comment = [[request userInfo] objectForKey:kCommentKey];

        [m_comments addObject:comment];
        m_commentCount++;
        
        if(m_commentCount == 1)
        {
            m_firstComment = comment;
        }
        
        m_comments = [NSMutableArray arrayWithArray:[m_comments sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate * first = [(Comment *)a time];
            NSDate * second = [(Comment *)b time];
            return [first compare:second];
        }]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCommentAddDidSucceedNotification object:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed with Error: %@", [request error]);
    m_downloadBuffer = nil;
}

-(BOOL)isEqual:(id)other
{
    if([other id] == m_id)
    {
        return YES;
    }
    return NO;
}

@end

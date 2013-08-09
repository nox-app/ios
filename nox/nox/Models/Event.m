//
//  Event.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Event.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "ImagePost.h"
#import "JSONKit.h"
#import "NSDictionary+Util.h"
#import "PlacePost.h"
#import "Post.h"
#import "Profile.h"
#import "TextPost.h"

NSString * const kPostsDidDownloadNotification = @"PostsDidDownloadNotification";
NSString * const kEventDidDownloadImageNotification = @"EventDidDownloadImageNotification";

@implementation Event

@synthesize id = m_id;
@synthesize name = m_name;
@synthesize startedAt = m_startedAt;
@synthesize endedAt = m_endedAt;
@synthesize updatedAt = m_updatedAt;
@synthesize resourceURI = m_resourceURI;
@synthesize posts = m_posts;
@synthesize images = m_images;

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super init])
    {
        [self setPropertiesFromDictionary:a_dictionary];
        [self initialize];
    }
    return self;
}

- (id)init
{
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    m_posts = [[NSMutableArray alloc] init];
    m_images = [[NSMutableArray alloc] init];
}

- (void)setPropertiesFromDictionary:(NSDictionary *)a_dictionary
{
    m_id = [[a_dictionary objectForKey:@"id"] intValue];
    m_name = [a_dictionary objectForKey:@"name"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    m_startedAt = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"created_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    m_endedAt = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"ended_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    m_updatedAt = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"updated_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    
    m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
}

- (void)updateWithDictionary:(NSDictionary *)a_dictionary
{
    [self setPropertiesFromDictionary:a_dictionary];
}

- (void)saveTextPost:(TextPost *)a_textPost
{
    //download events for the user
    NSString * textPostURLString = [kAPIBase stringByAppendingString:kAPITextPost];
    NSURL * textPostURL = [NSURL URLWithString:textPostURLString];
    
    NSMutableDictionary * postDictionary = [NSMutableDictionary dictionary];
    [postDictionary setValue:[a_textPost event] forKey:@"event"];
    [postDictionary setValue:[NSNumber numberWithFloat:[a_textPost location].coordinate.latitude] forKey:@"latitude"];
    [postDictionary setValue:[NSNumber numberWithFloat:[a_textPost location].coordinate.longitude] forKey:@"longitude"];
    [postDictionary setValue:[a_textPost body] forKey:@"body"];
    
    NSString * postJSON = [postDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:textPostURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[postJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestAddPostTag];
    [request startAsynchronous];
}

- (void)saveImagePost:(ImagePost *)a_imagePost
{
    NSString * imagePostURLString = [kAPIBase stringByAppendingString:kAPIImagePost];
    NSURL * imagePostURL = [NSURL URLWithString:imagePostURLString];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:imagePostURL];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:[a_imagePost event] forKey:@"event"];
    [request setPostValue:[NSNumber numberWithFloat:[a_imagePost location].coordinate.latitude] forKey:@"latitude"];
    [request setPostValue:[NSNumber numberWithFloat:[a_imagePost location].coordinate.longitude] forKey:@"longitude"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [request setPostValue:[formatter stringFromDate:[a_imagePost time]] forKey:@"created_at"];
    
    NSData * imageData = UIImageJPEGRepresentation([a_imagePost image], 1.0);
    [request setData:imageData withFileName:@"image.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    
    [request setDelegate:self];
    [request setTag:kRequestAddPostTag];
    [request startAsynchronous];
    
}

- (void)savePlacePost:(PlacePost *)a_placePost
{
    
}

- (void)addPost:(Post *)a_post
{
    [m_posts addObject:a_post];
    
    if([a_post type] == kImageType)
    {
        [m_images addObject:[(ImagePost *)a_post image]];
        [self saveImagePost:(ImagePost *)a_post];
    }
    else if([a_post type] == kPlaceType)
    {
        [self savePlacePost:(PlacePost *)a_post];
    }
    else if([a_post type] == kTextType)
    {
        [self saveTextPost:(TextPost *)a_post];
    }
    
    for(Post * post in m_posts)
    {
        NSLog(@"DATE: %f", [[post time] timeIntervalSince1970]);
    }
    
    //sort the array by time - is this necessary? Maybe just read from the array backwards...
    m_posts = [NSMutableArray arrayWithArray:[m_posts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate * first = [(Post *)a time];
        NSDate * second = [(Post *)b time];
        return [second compare:first];
    }]];
}

- (void)downloadPosts
{
    //download events for the user
    NSString * postURLString = [[kAPIBase stringByAppendingString:kAPIPosts] stringByAppendingString:[NSString stringWithFormat:@"%d", m_id]];
    NSURL * postURL = [NSURL URLWithString:postURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:postURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:@"Basic amRpcHJldGVAZ21haWwuY29tOnBhc3N3b3Jk"];
    [request setDelegate:self];
    [request setTag:kRequestDownloadPostsTag];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    int statusCode = [request responseStatusCode];
    NSLog(@"Status is: %d", statusCode);
    
    //@todo(jdiprete): get content length and init with capacity?
    m_downloadBuffer = nil;
    m_downloadBuffer = [[NSMutableData alloc] init];
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    [m_downloadBuffer appendData:a_data];
}

- (void)imageDownloaded:(NSNotification *)a_notification
{
    ImagePost * imagePost = [a_notification object];
    [m_images addObject:[imagePost image]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImagePostDidDownloadNotification object:imagePost];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventDidDownloadImageNotification object:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    if(m_downloadBuffer)
    {
        NSDictionary * posts = [[decoder objectWithData:m_downloadBuffer] objectForKey:@"objects"];
        m_downloadBuffer = nil;
        
        NSLog(@"Posts: %@", posts);
        if(posts)
        {
            //@todo(jdiprete): don't delete all the posts every time, just update the existing ones
            [m_posts removeAllObjects];
            
            for(NSDictionary * post in posts)
            {
                //@todo(jdiprete): is there a better way to determine post type?
                if([post objectForKey:@"body"] != nil)
                {
                    TextPost * textPost = [[TextPost alloc] initWithDictionary:post];
                    [m_posts addObject:textPost];
                }
                else if([post objectForKey:@"image"] != nil)
                {
                    ImagePost * imagePost = [[ImagePost alloc] initWithDictionary:post];
                    [m_posts addObject:imagePost];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:kImagePostDidDownloadNotification object:imagePost];
                }
                else
                {
                    PlacePost * placePost = [[PlacePost alloc] initWithDictionary:post];
                    [m_posts addObject:placePost];
                }
                
            }
            //sort the array by time - is this necessary? Maybe just read from the array backwards...
            m_posts = [NSMutableArray arrayWithArray:[m_posts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSDate * first = [(Post *)a time];
                NSDate * second = [(Post *)b time];
                return [second compare:first];
            }]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kPostsDidDownloadNotification object:self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed with Error: %@", [request error]);
    m_downloadBuffer = nil;
}

@end

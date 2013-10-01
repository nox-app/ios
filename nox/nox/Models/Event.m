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
#import "Invite.h"
#import "JSONKit.h"
#import "NSDictionary+Util.h"
#import "PlacePost.h"
#import "Post.h"
#import "Profile.h"
#import "TextPost.h"
#import "User.h"
#import "Venue.h"

NSString * const kPostsDidDownloadNotification = @"PostsDidDownloadNotification";
NSString * const kEventFinishedImageDownloadsNotification = @"EventFinishedImageDownloadsNotification";
NSString * const kAddPostDidSucceedNotification = @"AddPostDidSucceedNotification";
NSString * const kAddPostDidFailNotification = @"AddPostDidFailNotification";
NSString * const kInviteDidSucceedNotification = @"InviteDidSucceedNotification";

static NSString * const kPostKey = @"postKey";
static NSString * const kInviteKey = @"inviteKey";

@implementation Event

@synthesize id = m_id;
@synthesize name = m_name;
@synthesize startedAt = m_startedAt;
@synthesize endedAt = m_endedAt;
@synthesize updatedAt = m_updatedAt;
@synthesize resourceURI = m_resourceURI;
@synthesize posts = m_posts;
@synthesize imagePosts = m_imagePosts;
@synthesize imagesAreDownloading = m_imagesAreDownloading;
@synthesize postsAreDownloading = m_postsAreDownloading;
@synthesize invites = m_invites;
@synthesize creator = m_creator;

#pragma mark - Initialization

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
    m_imagePosts = [[NSMutableArray alloc] init];
    m_invites = [[NSMutableArray alloc] init];
}

- (void)setPropertiesFromDictionary:(NSDictionary *)a_dictionary
{
    m_id = [[a_dictionary objectForKey:@"id"] intValue];
    m_name = [a_dictionary objectForKey:@"name"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    m_startedAt = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"started_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    m_endedAt = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"ended_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    m_updatedAt = [formatter dateFromString:[[[a_dictionary objectForKeyNotNull:@"updated_at"] componentsSeparatedByString:@"."] objectAtIndex:0]];
    
    m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
    
    NSString * userResourceURI = [a_dictionary objectForKeyNotNull:@"creator"];
    m_creator = [[User alloc] init];
    [m_creator downloadUserWithResourceURI:userResourceURI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(creatorDidDownload) name:kUserDownloadDidSucceedNotification object:m_creator];
    
}

- (void)updateWithDictionary:(NSDictionary *)a_dictionary
{
    [self setPropertiesFromDictionary:a_dictionary];
}

#pragma mark - Event Members

- (void)creatorDidDownload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserDownloadDidSucceedNotification object:m_creator];
}

- (void)downloadEventMembers
{
    NSString * eventMembersURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:[kAPIInvite stringByAppendingString:[NSString stringWithFormat:@"%@%d", kAPIEventQuery, m_id]]]];
    NSURL * eventMembersURL = [NSURL URLWithString:eventMembersURLString];
    NSLog(@"Starting Request: %@", eventMembersURLString);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:eventMembersURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"GET"];
    [request setDelegate:self];
    [request setTag:kRequestDownloadMembersTag];
    [request startAsynchronous];
}

- (void)inviteUser:(User *)a_user withRSVP:(BOOL)a_rsvp
{
    Invite * invite = [[Invite alloc] init];
    [invite setUser:a_user];
    [invite setRsvp:a_rsvp];
    
    NSString * inviteURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIInvite]];
    NSURL * inviteURL = [NSURL URLWithString:inviteURLString];
    
    NSMutableDictionary * inviteDictionary = [NSMutableDictionary dictionary];
    [inviteDictionary setValue:[a_user resourceURI] forKey:@"user"];
    [inviteDictionary setValue:m_resourceURI forKey:@"event"];
    [inviteDictionary setValue:[NSNumber numberWithBool:a_rsvp] forKey:@"rsvp"];
    
    NSString * inviteJSON = [inviteDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:inviteURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[inviteJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setUserInfo:[NSDictionary dictionaryWithObject:invite forKey:kInviteKey]];
    [request setTag:kRequestInviteUserTag];
    [request startAsynchronous];
}

#pragma mark - Saving/Adding Posts

- (void)saveTextPost:(TextPost *)a_textPost
{
    NSString * textPostURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPITextPost]];
    NSURL * textPostURL = [NSURL URLWithString:textPostURLString];
    
    NSMutableDictionary * postDictionary = [NSMutableDictionary dictionary];
    [postDictionary setValue:[a_textPost event] forKey:@"event"];
    [postDictionary setValue:[NSNumber numberWithFloat:[a_textPost location].coordinate.latitude] forKey:@"latitude"];
    [postDictionary setValue:[NSNumber numberWithFloat:[a_textPost location].coordinate.longitude] forKey:@"longitude"];
    [postDictionary setValue:[a_textPost body] forKey:@"body"];
    
    NSString * postJSON = [postDictionary JSONString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:textPostURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[postJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestAddPostTag];
    [request setUserInfo:[NSDictionary dictionaryWithObject:a_textPost forKey:kPostKey]];
    [request startAsynchronous];
}

- (void)saveImagePost:(ImagePost *)a_imagePost
{
    NSString * imagePostURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIImagePost]];
    NSURL * imagePostURL = [NSURL URLWithString:imagePostURLString];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:imagePostURL];
    
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:[a_imagePost event] forKey:@"event"];
    [request setPostValue:[NSNumber numberWithFloat:[a_imagePost location].coordinate.latitude] forKey:@"latitude"];
    [request setPostValue:[NSNumber numberWithFloat:[a_imagePost location].coordinate.longitude] forKey:@"longitude"];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [request setPostValue:[formatter stringFromDate:[a_imagePost time]] forKey:@"created_at"];
    
    NSData * imageData = UIImageJPEGRepresentation([a_imagePost image], 0.8);
    [request setData:imageData withFileName:@"image.jpg" andContentType:@"image/jpeg" forKey:@"image"];
    
    [request setDelegate:self];
    [request setTag:kRequestAddPostTag];
    [request setUserInfo:[NSDictionary dictionaryWithObject:a_imagePost forKey:kPostKey]];
    [request startAsynchronous];
    
}

- (void)savePlacePost:(PlacePost *)a_placePost
{
    //download events for the user
    NSString * placePostURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPIPlacePost]];
    NSURL * placePostURL = [NSURL URLWithString:placePostURLString];
    
    NSMutableDictionary * postDictionary = [NSMutableDictionary dictionary];
    [postDictionary setValue:[a_placePost event] forKey:@"event"];
    [postDictionary setValue:[NSNumber numberWithFloat:[a_placePost location].coordinate.latitude] forKey:@"latitude"];
    [postDictionary setValue:[NSNumber numberWithFloat:[a_placePost location].coordinate.longitude] forKey:@"longitude"];
    [postDictionary setValue:[[a_placePost venue] id] forKey:@"venue"];
    
    NSString * postJSON = [postDictionary JSONString];
    NSLog(@"URL: %@", placePostURLString);
    NSLog(@"POST JSON: %@", postJSON);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:placePostURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[postJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestAddPostTag];
    [request setUserInfo:[NSDictionary dictionaryWithObject:a_placePost forKey:kPostKey]];
    [request startAsynchronous];
}

- (void)addPost:(Post *)a_post
{
    [m_posts addObject:a_post];
    
    if([a_post type] == kImageType)
    {
        [m_imagePosts addObject:a_post];
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
    m_postsAreDownloading = YES;

    NSString * postURLString = [kNoxBase stringByAppendingString:[[[kAPIBase stringByAppendingString:kAPIPosts] stringByAppendingString:kAPIEventQuery] stringByAppendingString:[NSString stringWithFormat:@"%d", m_id]]];
    NSURL * postURL = [NSURL URLWithString:postURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:postURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setDelegate:self];
    [request setTag:kRequestDownloadPostsTag];
    [request startAsynchronous];
}

- (void)downloadImagePosts
{
    m_imagesAreDownloading = YES;
    NSString * postURLString = [kNoxBase stringByAppendingString:[[[kAPIBase stringByAppendingString:kAPIImagePost] stringByAppendingString:kAPIEventQuery] stringByAppendingString:[NSString stringWithFormat:@"%d", m_id]]];
    NSURL * postURL = [NSURL URLWithString:postURLString];
    
    NSLog(@"Starting Request: %@", postURLString);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:postURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setDelegate:self];
    [request setTag:kRequestDownloadImagePostsTag];
    [request startAsynchronous];
}

- (void)downloadTextPosts
{
    NSString * postURLString = [kNoxBase stringByAppendingString:[[[kAPIBase stringByAppendingString:kAPITextPost] stringByAppendingString:kAPIEventQuery] stringByAppendingString:[NSString stringWithFormat:@"%d", m_id]]];
    NSURL * postURL = [NSURL URLWithString:postURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:postURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setDelegate:self];
    [request setTag:kRequestDownloadTextPostsTag];
    [request startAsynchronous];
}

- (void)downloadPlacePosts
{
    NSString * postURLString = [kNoxBase stringByAppendingString:[[[kAPIBase stringByAppendingString:kAPIPlacePost] stringByAppendingString:kAPIEventQuery] stringByAppendingString:[NSString stringWithFormat:@"%d", m_id]]];
    NSURL * postURL = [NSURL URLWithString:postURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:postURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setDelegate:self];
    [request setTag:kRequestDownloadPlacePostsTag];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    int statusCode = [request responseStatusCode];
    NSLog(@"Status is: %d", statusCode);
    
    switch([request tag])
    {
        case kRequestDownloadMembersTag:
            m_downloadMembersBuffer = nil;
            m_downloadMembersBuffer = [[NSMutableData alloc] init];
            break;
        case kRequestDownloadImagePostsTag:
            m_downloadImagePostsBuffer = nil;
            m_downloadImagePostsBuffer = [[NSMutableData alloc] init];
        case kRequestDownloadPlacePostsTag:
            m_downloadPlacePostsBuffer = nil;
            m_downloadPlacePostsBuffer = [[NSMutableData alloc] init];
        case kRequestDownloadTextPostsTag:
            m_downloadTextPostsBuffer = nil;
            m_downloadTextPostsBuffer = [[NSMutableData alloc] init];
        case kRequestDownloadPostsTag:
            m_downloadPostsBuffer = nil;
            m_downloadPostsBuffer = [[NSMutableData alloc] init];
        case kRequestAddPostTag:
            m_downloadAddPostBuffer = nil;
            m_downloadAddPostBuffer = [[NSMutableData alloc] init];
        default:
            break;
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    switch([request tag])
    {
        case kRequestDownloadMembersTag:
            [m_downloadMembersBuffer appendData:a_data];
            break;
        case kRequestDownloadImagePostsTag:
            [m_downloadImagePostsBuffer appendData:a_data];
        case kRequestDownloadPlacePostsTag:
            [m_downloadPlacePostsBuffer appendData:a_data];
        case kRequestDownloadTextPostsTag:
            [m_downloadTextPostsBuffer appendData:a_data];
        case kRequestDownloadPostsTag:
            [m_downloadPostsBuffer appendData:a_data];
        case kRequestAddPostTag:
            [m_downloadAddPostBuffer appendData:a_data];
        default:
            break;
    }
}

- (void)imageDownloaded:(NSNotification *)a_notification
{
    ImagePost * imagePost = [a_notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kImagePostDownloadDidSucceedNotification object:imagePost];
    [m_imagePosts addObject:imagePost];
    
    //@todo(jdiprete): check if all the image posts have been downloaded
    if([m_imagePosts count] == m_imagePostCount)
    {
        m_imagePosts = [NSMutableArray arrayWithArray:[m_imagePosts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate * first = [(ImagePost *)a time];
            NSDate * second = [(ImagePost *)b time];
            return [first compare:second];
        }]];
        m_imagesAreDownloading = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kEventFinishedImageDownloadsNotification object:self];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    if([request tag] == kRequestDownloadPostsTag)
    {
        if(m_downloadPostsBuffer)
        {
            NSDictionary * posts = [[decoder objectWithData:m_downloadPostsBuffer] objectForKey:@"objects"];
            m_downloadPostsBuffer = nil;

            if(posts)
            {
                //@todo(jdiprete): don't delete all the posts every time, just update the existing ones
                NSArray * tempPostsArray = [NSArray arrayWithArray:m_posts];
                [m_posts removeAllObjects];
                //[m_imagePosts removeAllObjects];
                
                for(NSDictionary * post in posts)
                {
                    //@todo(jdiprete): is there a better way to determine post type?
                    if([post objectForKey:@"body"] != nil)
                    {
                        TextPost * textPost = [[TextPost alloc] initWithDictionary:post];
                        BOOL postExists = NO;
                        for(Post * post in tempPostsArray)
                        {
                            if([post id] == [textPost id])
                            {
                                //@todo(jdiprete): Should we always update the icon?
                                if(![[post user] icon])
                                {
                                    [[post user] downloadIcon];
                                }
                                [m_posts addObject:post];
                                postExists = YES;
                                break;
                            }
                        }
                        if(!postExists)
                        {
                            [[textPost user] downloadIcon];
                            [m_posts addObject:textPost];
                        }
                    }
                    else if([post objectForKey:@"image"] != nil)
                    {
                        ImagePost * imagePost = [[ImagePost alloc] initWithDictionary:post];
                        BOOL postExists = NO;
                        for(Post * post in tempPostsArray)
                        {
                            if([post id] == [imagePost id])
                            {
                                //@todo(jdiprete): Should we always update the icon?
                                [[imagePost user] setIcon:[[post user] icon]];
                                [imagePost setImage:[(ImagePost *)post image]];
                                if(![[imagePost user] icon])
                                {
                                    [[imagePost user] downloadIcon];
                                }
                                if(![imagePost image])
                                {
                                    [imagePost downloadImage];
                                }
                                [m_posts addObject:imagePost];
                                postExists = YES;
                                break;
                            }
                        }
                        if(!postExists)
                        {
                            [[imagePost user] downloadIcon];
                            [imagePost downloadImage];
                            [m_posts addObject:imagePost];
                        }
                    }
                    else
                    {
                        PlacePost * placePost = [[PlacePost alloc] initWithDictionary:post];
                        BOOL postExists = NO;
                        for(Post * post in tempPostsArray)
                        {
                            if([post id] == [placePost id])
                            {
                                //@todo(jdiprete): Should we always update the icon?
                                if(![[post user] icon])
                                {
                                    [[post user] downloadIcon];
                                }
                                [m_posts addObject:post];
                                postExists = YES;
                                break;
                            }
                        }
                        if(!postExists)
                        {
                            [[placePost user] downloadIcon];
                            [m_posts addObject:placePost];
                        }
                    }
                    
                }
                //sort the array by time - is this necessary? Maybe just read from the array backwards...
                m_posts = [NSMutableArray arrayWithArray:[m_posts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Post *)a time];
                    NSDate * second = [(Post *)b time];
                    return [second compare:first];
                }]];
                m_imagePosts = [NSMutableArray arrayWithArray:[m_imagePosts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Post *)a time];
                    NSDate * second = [(Post *)b time];
                    return [first compare:second];
                }]];
            }
            //todo(jdiprete):add a fail case also
            m_postsAreDownloading = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:kPostsDidDownloadNotification object:self];
        }
    }
    else if([request tag] == kRequestDownloadImagePostsTag)
    {
        if(m_downloadImagePostsBuffer)
        {
            NSDictionary * posts = [[decoder objectWithData:m_downloadImagePostsBuffer] objectForKey:@"objects"];
            m_downloadImagePostsBuffer = nil;

            if(posts)
            {
                m_imagePostCount = [posts count];
                if(m_imagePostCount == 0)
                {
                    m_imagesAreDownloading = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEventFinishedImageDownloadsNotification object:self];
                }
                for(NSDictionary * post in posts)
                {
                    NSLog(@"REQUEST URL: %@", [[request url] absoluteString]);
                    ImagePost * imagePost = [[ImagePost alloc] initWithDictionary:post];
                    if(![m_posts containsObject:imagePost])
                    {
                        [imagePost downloadImage];
                        [m_posts addObject:imagePost];
                    }
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:kImagePostDownloadDidSucceedNotification object:imagePost];
                }
                //sort the array by time - is this necessary? Maybe just read from the array backwards...
                m_posts = [NSMutableArray arrayWithArray:[m_posts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Post *)a time];
                    NSDate * second = [(Post *)b time];
                    return [second compare:first];
                }]];
                m_imagePosts = [NSMutableArray arrayWithArray:[m_imagePosts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Post *)a time];
                    NSDate * second = [(Post *)b time];
                    return [first compare:second];
                }]];
            }
            else
            {
                m_imagesAreDownloading = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kEventFinishedImageDownloadsNotification object:self];
            }
            //todo(jdiprete):add a fail case also
            [[NSNotificationCenter defaultCenter] postNotificationName:kPostsDidDownloadNotification object:self];
        }
    }
    else if([request tag] == kRequestDownloadPlacePostsTag)
    {
        if(m_downloadPlacePostsBuffer)
        {
            NSDictionary * posts = [[decoder objectWithData:m_downloadPlacePostsBuffer] objectForKey:@"objects"];
            m_downloadPlacePostsBuffer = nil;

            if(posts)
            {
                for(NSDictionary * post in posts)
                {
                    PlacePost * placePost = [[PlacePost alloc] initWithDictionary:post];
                    if(![m_posts containsObject:placePost])
                    {
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
            //todo(jdiprete):add a fail case also
            [[NSNotificationCenter defaultCenter] postNotificationName:kPostsDidDownloadNotification object:self];
        }
    }
    else if([request tag] == kRequestDownloadTextPostsTag)
    {
        if(m_downloadTextPostsBuffer)
        {
            NSDictionary * posts = [[decoder objectWithData:m_downloadTextPostsBuffer] objectForKey:@"objects"];
            m_downloadTextPostsBuffer = nil;

            if(posts)
            {
                for(NSDictionary * post in posts)
                {
                    TextPost * textPost = [[TextPost alloc] initWithDictionary:post];
                    if(![m_posts containsObject:textPost])
                    {
                        [m_posts addObject:textPost];
                    }
                }
                //sort the array by time - is this necessary? Maybe just read from the array backwards...
                m_posts = [NSMutableArray arrayWithArray:[m_posts sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    NSDate * first = [(Post *)a time];
                    NSDate * second = [(Post *)b time];
                    return [second compare:first];
                }]];
            }
            //todo(jdiprete):add a fail case also
            [[NSNotificationCenter defaultCenter] postNotificationName:kPostsDidDownloadNotification object:self];
        }
    }
    else if([request tag] == kRequestAddPostTag)
    {
        if(m_downloadAddPostBuffer)
        {
            Post * post = [[request userInfo] objectForKey:kPostKey];
            NSDictionary * postDictionary = [decoder objectWithData:m_downloadAddPostBuffer];
            m_downloadAddPostBuffer = nil;
            if(postDictionary)
            {
                [post updateWithDictionary:postDictionary];
            }
            //@todo(jdiprete): post notification for success or failure
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddPostDidSucceedNotification object:post];
        }
    }
    else if([request tag] == kRequestDownloadMembersTag)
    {
        if(m_downloadMembersBuffer)
        {
            [m_invites removeAllObjects];
            NSDictionary * response = [decoder objectWithData:m_downloadMembersBuffer];
            NSLog(@"REQUEST: %@", [[request url] absoluteString]);
            NSLog(@"TAG: %d", [request tag]);
            NSLog(@"RESPONSE: %@", response);
            m_downloadMembersBuffer = nil;
            if(response)
            {
                NSArray * inviteArray = [response objectForKey:@"objects"];
                for(NSDictionary * inviteDictionary in inviteArray)
                {
                    Invite * invite = [[Invite alloc] initWithDictionary:inviteDictionary];
                    [invite lookupUser];
                    [m_invites addObject:invite];
                }
            }
        }
    }
    else if([request tag] == kRequestInviteUserTag)
    {
        Invite * invite = [[request userInfo] objectForKey:kInviteKey];
        [m_invites addObject:invite];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInviteDidSucceedNotification object:nil];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed with Error: %@", [request error]);
    switch([request tag])
    {
        case kRequestDownloadMembersTag:
            m_downloadMembersBuffer = nil;
            break;
        case kRequestDownloadImagePostsTag:
            m_downloadImagePostsBuffer = nil;
        case kRequestDownloadPlacePostsTag:
            m_downloadPlacePostsBuffer = nil;
        case kRequestDownloadTextPostsTag:
            m_downloadTextPostsBuffer = nil;
        case kRequestDownloadPostsTag:
            m_downloadPostsBuffer = nil;
        case kRequestAddPostTag:
            m_downloadAddPostBuffer = nil;
        default:
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

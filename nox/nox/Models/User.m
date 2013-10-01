//
//  User.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "User.h"

#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "JSONKit.h"
#import "NSDictionary+Util.h"
#import "Profile.h"

NSString * const kUserCreationDidSucceedNotification = @"UserCreationDidSucceedNotification";
NSString * const kUserCreationDidFailNotification = @"UserCreationDidFailNotification";
NSString * const kUserDownloadDidSucceedNotification = @"UserDownloadDidSucceedNotification";
NSString * const kIconDownloadDidSucceedNotification = @"IconDownloadDidSucceedNotification";
NSString * const kIconDownloadDidFailNotification = @"IconDownloadDidFailNotification";

@implementation User

@synthesize id = m_id;
@synthesize firstName = m_firstName;
@synthesize lastName = m_lastName;
@synthesize email = m_email;
@synthesize phoneNumber = m_phoneNumber;
@synthesize createdAt = m_createdAt;
@synthesize hasIcon = m_hasIcon;
@synthesize icon = m_icon;
@synthesize resourceURI = m_resourceURI;

- (id)initWithEmail:(NSString *)a_email
{
    if(self = [super init])
    {
        m_email = a_email;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)a_dictionary
{
    if(self = [super init])
    {
        [self setPropertiesFromDictionary:a_dictionary];
    }
    return self;
}

- (void)downloadUserWithResourceURI:(NSString *)a_resourceURI
{
    m_resourceURI = a_resourceURI;
    //NSString * userURLString = [kNoxBase stringByAppendingString:a_resourceURI];
    //tmp get red of this slash
    NSString * userURLString = [kNoxBase stringByAppendingString:[a_resourceURI stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""]];
    
    NSLog(@"Downloading User: %@", userURLString);
    NSURL * userURL = [NSURL URLWithString:userURLString];
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:userURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    NSLog(@"AUTHORIZATION: %@", [NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]);
    [request setRequestMethod:@"GET"];
    [request setDelegate:self];
    [request setTag:kRequestGetUserTag];
    [request startAsynchronous];
}

- (void)setPropertiesFromDictionary:(NSDictionary *)a_dictionary
{
    m_email = [a_dictionary objectForKeyNotNull:@"email"];
    m_firstName = [a_dictionary objectForKeyNotNull:@"first_name"];
    m_lastName = [a_dictionary objectForKeyNotNull:@"last_name"];
    m_resourceURI = [a_dictionary objectForKeyNotNull:@"resource_uri"];
    m_id = [[a_dictionary objectForKeyNotNull:@"id"] intValue];
    m_iconPath = [a_dictionary objectForKeyNotNull:@"icon"];
}

- (void)saveWithPassword:(NSString *)a_password
{
    //download events for the user
    NSString * createUserURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPICreateUser]];
    NSURL * createUserURL = [NSURL URLWithString:createUserURLString];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:createUserURL];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:m_email forKey:@"email"];
    [request setPostValue:m_firstName forKey:@"first_name"];
    [request setPostValue:m_lastName forKey:@"last_name"];
    [request setPostValue:a_password forKey:@"password"];
    [request setPostValue:m_phoneNumber forKey:@"phone_number"];
    if(m_icon != nil)
    {
        NSData * imageData = UIImageJPEGRepresentation(m_icon, 0.8);
        [request setData:imageData withFileName:@"image.jpg" andContentType:@"image/jpeg" forKey:@"icon"];
    }
    [request setDelegate:self];
    [request setTag:kRequestCreateUserTag];
    [request startAsynchronous];
}

- (void)iconDownloadDidSucceed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIconDownloadDidSucceedNotification object:self];
}

- (void)iconDownloadDidFail
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kIconDownloadDidFailNotification object:self];
}

- (void)downloadIcon
{
    if(m_iconPath)
    {
        NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:m_iconPath] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
        NSURLConnection * connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
    }
}

//should this be setIcon instead?
- (void)updateIcon:(UIImage *)a_icon
{
    m_icon = a_icon;
    NSString * userURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:[kAPIUser stringByAppendingString:[NSString stringWithFormat:@"%d/", m_id]]]];
    NSURL * userURL = [NSURL URLWithString:userURLString];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:userURL];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"PUT"];
    NSData * imageData = UIImageJPEGRepresentation(m_icon, 0.8);
    [request setData:imageData withFileName:@"image.jpg" andContentType:@"image/jpeg" forKey:@"icon"];
    [request setDelegate:self];
    [request setTag:kRequestUpdateIconTag];
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    int statusCode = [request responseStatusCode];
    NSLog(@"Status is: %d", statusCode);
    
    if([request tag] == kRequestCreateUserTag)
    {
        if(statusCode == 201)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserCreationDidSucceedNotification object:self];
        }
    }
    
    switch([request tag])
    {
        case kRequestGetUserTag:
            m_downloadBuffer = nil;
            m_downloadBuffer = [[NSMutableData alloc] init];
            break;
        default:
            break;
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    switch([request tag])
    {
        case kRequestGetUserTag:
            [m_downloadBuffer appendData:a_data];
            break;
        default:
            break;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if([request tag] == kRequestGetUserTag)
    {
        JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        
        if(m_downloadBuffer)
        {
            NSDictionary * userDictionary = [decoder objectWithData:m_downloadBuffer];
            NSLog(@"User Downloaded: %@", userDictionary);
            m_downloadBuffer = nil;
            if(userDictionary)
            {
                [self setPropertiesFromDictionary:userDictionary];
                [self downloadIcon];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownloadDidSucceedNotification object:self];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    switch([request tag]) {
        case kRequestGetUserTag:
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserCreationDidFailNotification object:self];
            m_downloadBuffer = nil;
            break;
        default:
            break;
    }
    NSLog(@"Request Failed with Error: %@", [request error]);
    
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)a_connection didReceiveResponse:(NSURLResponse *)a_response
{
    m_iconDownloadBuffer = nil;
    if([a_response expectedContentLength] == NSURLResponseUnknownLength)
    {
        m_iconDownloadBuffer = [[NSMutableData alloc] init];
    }
    else
    {
        m_iconDownloadBuffer = [[NSMutableData alloc] initWithCapacity:[a_response expectedContentLength]];
    }
}

- (void)connection:(NSURLConnection *)a_connection didReceiveData:(NSData *)a_data
{
    [m_iconDownloadBuffer appendData:a_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)a_connection
{
    m_icon = [UIImage imageWithData:m_iconDownloadBuffer];
    [self iconDownloadDidSucceed];
    m_iconDownloadBuffer = nil;
}

- (void)connection:(NSURLConnection *)a_connection didFailWithError:(NSError *)a_error
{
    m_iconDownloadBuffer = nil;
    [self iconDownloadDidFail];
    NSLog(@"Request Failed with Error: %@", a_error);
}

@end

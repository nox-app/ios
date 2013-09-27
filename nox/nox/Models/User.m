//
//  User.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "User.h"

#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "JSONKit.h"
#import "NSDictionary+Util.h"
#import "Profile.h"

NSString * const kUserCreationDidSucceedNotification = @"UserCreationDidSucceedNotification";
NSString * const kUserCreationDidFailNotification = @"UserCreationDidFailNotification";
NSString * const kUserDownloadDidSucceedNotification = @"UserDownloadDidSucceedNotification";

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
}

- (void)saveWithPassword:(NSString *)a_password
{
    //download events for the user
    NSString * createUserURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPICreateUser]];
    NSURL * createUserURL = [NSURL URLWithString:createUserURLString];
    
    NSMutableDictionary * userDictionary = [NSMutableDictionary dictionary];
    [userDictionary setValue:m_email forKey:@"email"];
    [userDictionary setValue:m_firstName forKey:@"first_name"];
    [userDictionary setValue:m_lastName forKey:@"last_name"];
    [userDictionary setValue:a_password forKey:@"password"];
    [userDictionary setValue:m_phoneNumber forKey:@"phone_number"];
    
    NSString * userJSON = [userDictionary JSONString];
    
    NSLog(@"CREATE USER: %@", createUserURLString);
    NSLog(@"CREATE USER JSON: %@", userJSON);
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:createUserURL];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:kAPIKeyFormat, [[[Profile sharedProfile] user] email], [[Profile sharedProfile] apiKey]]];
    [request setRequestMethod:@"POST"];
    [request appendPostData:[userJSON dataUsingEncoding:NSUTF8StringEncoding]];
    [request setDelegate:self];
    [request setTag:kRequestCreateUserTag];
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
    if([request tag] == kRequestGetUserTag)
    {
        JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        
        if(m_downloadBuffer)
        {
            NSDictionary * userDictionary = [decoder objectWithData:m_downloadBuffer];
            NSLog(@"REQEUST: %@", [[request url] absoluteString]);
            NSLog(@"User Downloaded: %@", userDictionary);
            m_downloadBuffer = nil;
            if(userDictionary)
            {
                [self setPropertiesFromDictionary:userDictionary];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserDownloadDidSucceedNotification object:self];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if([request tag] == kRequestCreateUserTag)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserCreationDidFailNotification object:self];
    }
    NSLog(@"Request Failed with Error: %@", [request error]);
    m_downloadBuffer = nil;
}

@end

//
//  User.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequestDelegate.h"

extern NSString * const kUserCreationDidSucceedNotification;
extern NSString * const kUserCreationDidFailNotification;
extern NSString * const kUserDownloadDidSucceedNotification;
extern NSString * const kIconDownloadDidSucceedNotification;
extern NSString * const kIconDownloadDidFailNotification;

typedef enum UserRequestTag
{
    kRequestCreateUserTag = 1,
    kRequestGetUserTag,
    kRequestUpdateIconTag,
    kRequestDownloadIconTag
} UserRequestTag;

@interface User : NSObject<ASIHTTPRequestDelegate, NSURLConnectionDelegate>
{
    NSInteger m_id;
    NSString * m_firstName;
    NSString * m_lastName;
    NSString * m_email;
    NSString * m_phoneNumber;
    NSDate * m_createdAt;
    BOOL m_hasIcon;
    UIImage * m_icon;
    
    NSString * m_iconPath;
    NSString * m_resourceURI;
    
    NSMutableData * m_downloadBuffer;
    NSMutableData * m_iconDownloadBuffer;
}

@property NSInteger id;
@property NSString * firstName;
@property NSString * lastName;
@property NSString * email;
@property NSString * phoneNumber;
@property NSDate * createdAt;
@property BOOL hasIcon;
@property UIImage * icon;
@property NSString * resourceURI;

- (id)initWithEmail:(NSString *)a_email;
- (id)initWithDictionary:(NSDictionary *)a_dictionary;
- (void)saveWithPassword:(NSString *)a_password;
- (void)updateIcon:(UIImage *)a_icon;
- (void)downloadUserWithResourceURI:(NSString *)a_resourceURI;
- (void)downloadIcon;

@end

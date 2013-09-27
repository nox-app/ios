//
//  Invite.h
//  nox
//
//  Created by Justine DiPrete on 9/26/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Invite : NSObject
{
    NSInteger m_id;
    NSString * m_resourceURI;
    NSString * m_userResourceURI;
    User * m_user;
    BOOL m_rsvp;
}

@property NSInteger id;
@property NSString * resourceURI;
@property NSString * userResourceURI;
@property User * user;
@property BOOL rsvp;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;
- (void)lookupUser;

@end

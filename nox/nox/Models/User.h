//
//  User.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    NSInteger m_id;
    NSString * m_firstName;
    NSString * m_lastName;
    NSString * m_email;
    NSString * m_phoneNumber;
    NSDate * m_createdAt;
    BOOL m_hasIcon;
    UIImage * m_icon;
}

@property NSInteger id;
@property NSString * firstName;
@property NSString * lastName;
@property NSString * email;
@property NSString * phoneNumber;
@property NSDate * createdAt;
@property BOOL hasIcon;
@property UIImage * icon;

@end

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
    bool m_hasIcon;
    UIImage * m_icon;
}

@property (readonly) NSInteger id;
@property (readonly) NSString * firstName;
@property (readonly) NSString * lastName;
@property (readonly) NSString * email;
@property (readonly) NSString * phoneNumber;
@property (readonly) NSDate * createdAt;
@property (readonly) bool hasIcon;
@property (readonly) UIImage * icon;

@end

//
//  Profile.h
//  nox
//
//  Created by Justine DiPrete on 6/30/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Profile : NSObject
{
    User * m_user;
    NSMutableArray * m_events;
}

@property (readonly) NSMutableArray * events;
@property (nonatomic) User * user;

+ (Profile *)sharedProfile;

@end

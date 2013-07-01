//
//  Event.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
    NSInteger m_id;
    NSString * m_name;
    NSDate * m_startedAt;
    NSDate * m_endedAt;
    NSDate * m_updatedAt;
    NSString * m_assetDir;
    
    NSArray * m_postsArray;
}

@property (readonly) NSInteger id;
@property (readonly) NSString * name;
@property (readonly) NSDate * startedAt;
@property (readonly) NSDate * endedAt;
@property (readonly) NSDate * updatedAt;
@property (readonly) NSString * assetDir;

@end

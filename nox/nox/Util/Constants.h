//
//  Constants.h
//  nox
//
//  Created by Justine DiPrete on 7/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNoxBase;
extern NSString * const kAPIBase;
extern NSString * const kAPIEvents;
extern NSString * const kAPILogin;
extern NSString * const kAPIPosts;
extern NSString * const kAPITextPost;
extern NSString * const kAPIImagePost;
extern NSString * const kAPIPlacePost;

extern NSString * const kEventsDownloadFinishedNotification;
extern NSString * const kEventCreationSucceededNotification;
extern NSString * const kEventCreationFailedNotification;

extern NSInteger const kMaxCharacterLimit;

@interface Constants : NSObject

@end

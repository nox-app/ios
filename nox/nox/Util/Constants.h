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
extern NSString * const kAPIEventQuery;
extern NSString * const kAPITextPost;
extern NSString * const kAPIImagePost;
extern NSString * const kAPIPlacePost;
extern NSString * const kAPIComments;
extern NSString * const kAPIPostQuery;
extern NSString * const kAPICreateUser;
extern NSString * const kAPISearchUsers;
extern NSString * const kAPIUser;
extern NSString * const kAPIPostLike;
extern NSString * const kAPIPostDislike;
extern NSString * const kAPIInvite;
extern NSString * const kAPIKeyFormat;

extern NSString * const kEventsDownloadFinishedNotification;
extern NSString * const kEventCreationSucceededNotification;
extern NSString * const kEventCreationFailedNotification;

extern NSInteger const kMaxCharacterLimit;

@interface Constants : NSObject

+ (UIColor *)noxColor;
+ (UIColor *)navigationBarColor;

@end

//
//  Constants.m
//  nox
//
//  Created by Justine DiPrete on 7/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Constants.h"

NSString * const kNoxBase = @"http://www.nox-app.com/";
//NSString * const kNoxBase = @"http://192.168.1.102:8000/";
NSString * const kAPIBase = @"api/v1/";
NSString * const kAPIEvents = @"event/";
NSString * const kAPIPosts = @"post/";
NSString * const kAPIEventQuery = @"?event__id=";
NSString * const kAPILogin = @"user/login/";
NSString * const kAPITextPost = @"text_post/";
NSString * const kAPIImagePost = @"image_post/";
NSString * const kAPIPlacePost = @"place_post/";
NSString * const kAPIComments = @"comment/";
NSString * const kAPIPostQuery = @"?post__id=";
NSString * const kAPICreateUser = @"create_user/";
NSString * const kAPIUser = @"user/";
NSString * const kAPISearchUsers = @"user/search/";
NSString * const kAPIPostLike = @"post_like/";
NSString * const kAPIPostDislike = @"post_dislike/";
NSString * const kAPIInvite = @"invite/";

NSString * const kAPIKeyFormat = @"ApiKey %@:%@";

NSString * const kEventsDownloadFinishedNotification = @"EventsDownloadFinishedNotification";
NSString * const kEventCreationSucceededNotification = @"EventCreationSucceededNotification";
NSString * const kEventCreationFailedNotification = @"EventCreationFailedNotification";

//@todo(jdiprete): Do we want some kind of max?
NSInteger const kMaxCharacterLimit = 1000;

NSInteger const kImageDimension = 310;

@implementation Constants

+ (UIColor *)noxColor
{
    return [UIColor colorWithRed:40.0/255.0 green:12.0/255.0 blue:98.0/255.0 alpha:1];
}

+ (UIColor *)navigationBarColor
{
    return [UIColor colorWithRed:10.0/255.0 green:2.0/255.0 blue:88.0/255.0 alpha:1];
}

@end

//
//  Constants.m
//  nox
//
//  Created by Justine DiPrete on 7/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Constants.h"

NSString * const kNoxBase = @"http://192.168.1.16:8000/";
NSString * const kAPIBase = @"http://192.168.1.16:8000/api/v1/";
NSString * const kAPIEvents = @"event/";
NSString * const kAPIPosts = @"post/?event__id=";
NSString * const kAPILogin = @"user/login/";
NSString * const kAPITextPost = @"text_post/";
NSString * const kAPIImagePost = @"image_post/";
NSString * const kAPIPlacePost = @"place_post/";

NSString * const kEventsDownloadFinishedNotification = @"EventsDownloadFinishedNotification";
NSString * const kEventCreationSucceededNotification = @"EventCreationSucceededNotification";
NSString * const kEventCreationFailedNotification = @"EventCreationFailedNotification";

NSInteger const kMaxCharacterLimit = 140;

@implementation Constants

@end

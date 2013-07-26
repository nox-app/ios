//
//  Venue.h
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kVenueIconDidDownloadNotification;

@class Location;

@interface Venue : NSObject
{
    NSString * m_iconURL;
    UIImage * m_iconImage;
    NSString * m_id;
    NSString * m_name;
    NSString * m_phoneNumber;
    NSString * m_URL;
    Location * m_location;
}

@property (nonatomic, readonly) NSString * iconURL;
@property (nonatomic, readonly) UIImage * iconImage;
@property (nonatomic, readonly) NSString * id;
@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSString * phoneNumber;
@property (nonatomic, readonly) NSString * URL;
@property (nonatomic, readonly) Location * location;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

@end
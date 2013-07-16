//
//  Location.h
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject
{
    NSString * m_address;
    NSString * m_countryCode;
    NSString * m_city;
    NSString * m_country;
    NSString * m_postalCode;
    NSString * m_state;
    NSString * m_crossStreet;
    NSInteger m_distance;
    CLLocationCoordinate2D m_coordinate;
    
}

@property (nonatomic, readonly) NSString * address;
@property (nonatomic, readonly) NSString * countryCode;
@property (nonatomic, readonly) NSString * city;
@property (nonatomic, readonly) NSString * country;
@property (nonatomic, readonly) NSString * postalCode;
@property (nonatomic, readonly) NSString * state;
@property (nonatomic, readonly) NSString * crossStreet;
@property (nonatomic, readonly) NSInteger distance;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithDictionary:(NSDictionary *)a_dictionary;

@end

//
//  CheckInViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class Event;
@class RoundedView;
@class Venue;

@interface CheckInViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIToolbar * m_toolbar;
    IBOutlet MKMapView * m_mapView;
    IBOutlet UITableView * m_tableView;
    
    NSMutableData * m_downloadBuffer;
    
    NSMutableArray * m_venues;
    
    BOOL m_hasUpdatedVenues;
    
    Event * m_event;
    
    IBOutlet RoundedView * m_confirmView;
    IBOutlet UIImageView * m_confirmIconView;
    IBOutlet UILabel * m_confirmPlaceName;
    IBOutlet UILabel * m_confirmAddressLabel;
    IBOutlet UILabel * m_confirmCityStateLabel;
    
    Venue * m_currentVenue;
}

- (id)initWithEvent:(Event *)a_event;

- (IBAction)cancelPressed;

- (IBAction)cancelConfirmPressed:(id)sender;
- (IBAction)confirmPressed:(id)sender;

@end

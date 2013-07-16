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

@interface CheckInViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIToolbar * m_toolbar;
    IBOutlet MKMapView * m_mapView;
    IBOutlet UITableView * m_tableView;
    
    NSMutableData * m_downloadBuffer;
    
    NSMutableArray * m_venues;
    
    BOOL m_hasUpdatedVenues;
    
    Event * m_event;
}

- (id)initWithEvent:(Event *)a_event;

- (IBAction)cancelPressed;

@end

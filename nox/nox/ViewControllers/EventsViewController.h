//
//  EventsViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingViewControllerDelegate.h"

@class Event;

@interface EventsViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, SettingViewControllerDelegate>
{
    IBOutlet UITableView * m_eventsTableView;
    IBOutlet UIActivityIndicatorView * m_startEventSpinner;
    IBOutlet UIButton * m_startEventButton;
}

- (IBAction)startEventPressed:(id)sender;

@end

//
//  EventsViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@protocol EventsViewControllerDelegate

- (void)pushEventViewControllerWithEvent:(Event *)a_event;

@end

@interface EventsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EventsViewControllerDelegate>
{
    IBOutlet UITableView * m_eventsTableView;
}

- (IBAction)startEventPressed:(id)sender;

@end

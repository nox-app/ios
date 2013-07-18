//
//  EventViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface EventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    Event * m_event;
    
    IBOutlet UITableView * m_tableView;
}


- (id)initWithEvent:(Event *)a_event;

- (IBAction)photoPressed:(id)sender;
- (IBAction)checkInPressed:(id)sender;
- (IBAction)statusUpdatePressed:(id)sender;

@end

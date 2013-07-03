//
//  CreateEventViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EventsViewController.h"

@interface CreateEventViewController : UIViewController <UITextFieldDelegate>
{
    id m_delegate;
    
    IBOutlet UITextField * m_titleTextField;
    IBOutlet UIDatePicker * m_endDatePicker;
}

- (id)initWithDelegate:(id<EventsViewControllerDelegate>)a_delegate;

- (IBAction)startPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end

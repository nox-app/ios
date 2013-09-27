//
//  EventSettingsViewController.h
//  nox
//
//  Created by Justine DiPrete on 9/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EventSettingsViewControllerDelegate.h"

@class Event;

@interface EventSettingsViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    id<EventSettingsViewControllerDelegate> m_delegate;
    
    Event * m_event;
    
    IBOutlet UITextField * m_titleTextField;
    IBOutlet UITextField * m_startTextField;
    IBOutlet UITextField * m_endTextField;
    IBOutlet UITextField * m_locationTextField;
    
    NSDate * m_currentStartDate;
    NSDate * m_currentEndDate;
    UIDatePicker * m_datePicker;
    
    UITextField * m_currentTextField;
}

@property id<EventSettingsViewControllerDelegate> delegate;

- (id)initWithEvent:(Event *)a_event;

- (IBAction)saveEventPressed:(id)sender;
- (IBAction)deleteEventPressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;

@end

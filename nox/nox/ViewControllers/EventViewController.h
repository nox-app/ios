//
//  EventViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class Event;

@interface EventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
{
    Event * m_event;
    
    IBOutlet UITableView * m_tableView;
    IBOutlet UIToolbar * m_postToolbar;
    
    IBOutlet UIView * m_settingsView;
    IBOutlet UIImageView * m_settingsTabView;
    float m_settingsMaximumY;
    float m_settingsMinimumY;
    float m_settingsStartY;
    
    IBOutlet UITextField * m_eventNameTextField;
    UIDatePicker * m_endDatePicker;
    
}


- (id)initWithEvent:(Event *)a_event;

- (IBAction)photoPressed:(id)sender;
- (IBAction)checkInPressed:(id)sender;
- (IBAction)statusUpdatePressed:(id)sender;
- (IBAction)saveSettingsPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
@end

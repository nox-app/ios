//
//  CreateEventViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CreateEventViewController.h"

#import "Event.h"
#import "EventViewController.h"
#import "EventsViewController.h"
#import "Profile.h"

@interface CreateEventViewController ()

@end

@implementation CreateEventViewController

- (id)initWithDelegate:(id<EventsViewControllerDelegate>)a_delegate
{
    if(self = [super init])
    {
        m_delegate = a_delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    NSString * dateString = [formatter stringFromDate:[NSDate date]];
    [m_titleTextField setText:[NSString stringWithFormat:@"%@ Event", dateString]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //Disallow recognition of tap gestures for the cancel button
    if([touch.view.superview isKindOfClass:[UIToolbar class]])
    {
        return NO;
    }
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [m_endDatePicker setDate:endDate animated:YES];
}

#pragma mark - IBActions

- (IBAction)startPressed:(id)sender
{
    Event * event = [[Event alloc] init];
    [event setName:[m_titleTextField text]];
    [event setStartedAt:[NSDate date]];
    [event setEndedAt:[m_endDatePicker date]];
    
    [[[Profile sharedProfile] events] addObject:event];
    
    //@todo(jdiprete): Send info to server, wait for response with id before continuing
    
    [self dismissViewControllerAnimated:NO completion:^(void)
     {
         [m_delegate pushEventViewControllerWithEvent:event];
     }];
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard
{
    [m_titleTextField resignFirstResponder];
}

@end

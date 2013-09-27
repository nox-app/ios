//
//  EventSettingsViewController.m
//  nox
//
//  Created by Justine DiPrete on 9/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EventSettingsViewController.h"

#import "CheckInViewController.h"
#import "Event.h"
#import "Profile.h"
#import "Util.h"

@interface EventSettingsViewController ()

@end

@implementation EventSettingsViewController

@synthesize delegate = m_delegate;

- (id)initWithEvent:(Event *)a_event
{
    if(self = [super init])
    {
        m_event = a_event;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    m_currentStartDate = [m_event startedAt];
    m_currentEndDate = [m_event endedAt];
    
    [m_titleTextField setText:[m_event name]];
    
    //@todo(jdiprete): this should be from the event
    [m_locationTextField setText:[[Profile sharedProfile] currentCity]];
    
    [self setDateFields];
}

- (void)setDateFields
{
    [m_startTextField setText:[Util stringFromDate:m_currentStartDate]];
    if(m_currentEndDate == nil)
    {
        [m_endTextField setText:@"Ongoing"];
    }
    else
    {
        [m_endTextField setText:[Util stringFromDate:m_currentEndDate]];
    }
}

- (void)deleteEvent
{
    [[Profile sharedProfile] deleteEvent:m_event];
    [m_delegate dismissViewController];
}

#pragma mark - IBActions

- (IBAction)saveEventPressed:(id)sender
{
    [m_event setName:[m_titleTextField text]];
    [m_event setStartedAt:m_currentStartDate];
    [m_event setEndedAt:m_currentEndDate];
    [[Profile sharedProfile] updateEvent:m_event];
    [m_delegate updateEvent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteEventPressed:(id)sender
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure you want to delete this event?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Alert View Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [alertView cancelButtonIndex])
    {
        [self deleteEvent];
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isEqual:m_startTextField] || [textField isEqual:m_endTextField])
    {
        [m_currentTextField resignFirstResponder];
        m_currentTextField = textField;
        [self addDateActionSheetForTextField:textField];
        return NO;
    }
    else if([textField isEqual:m_locationTextField])
    {
        [m_currentTextField resignFirstResponder];
        m_currentTextField = textField;
        CheckInViewController * checkInViewController = [[CheckInViewController alloc] initWithEvent:m_event];
        [self presentViewController:checkInViewController animated:YES completion:nil];
    }
    m_currentTextField = textField;
    return YES;
}

- (void)addDateActionSheetForTextField:(UITextField *)a_textField
{
    m_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 50, 100, 116)];
    NSString * cancelButtonTitle;
    if([a_textField isEqual:m_endTextField])
    {
        cancelButtonTitle = @"Ongoing";
        if([m_event endedAt] != nil)
        {
            [m_datePicker setDate:[m_event endedAt]];
        }
    }
    else
    {
        [m_datePicker setDate:[m_event startedAt]];
        cancelButtonTitle = @"Cancel";
    }
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Date" delegate:self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:@"Set", nil];
    [actionSheet showInView:self.view];
    [actionSheet setFrame:CGRectMake(0, 200, self.view.frame.size.width, 383)];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    [actionSheet addSubview:m_datePicker];
    
    //Gets an array af all of the subviews of our actionSheet
    NSArray * subviews = [actionSheet subviews];
    for(UIView * view in subviews)
    {
        NSLog(@"VIEW: %@", view);
    }
    
    [[subviews objectAtIndex:2] setFrame:CGRectMake(20, 266, 280, 46)];
    [[subviews objectAtIndex:3] setFrame:CGRectMake(20, 317, 280, 46)];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([m_currentTextField isEqual:m_startTextField])
    {
        if(buttonIndex != [actionSheet cancelButtonIndex])
        {
            m_currentStartDate = [m_datePicker date];
            
        }
    }
    else
    {
        if(buttonIndex == [actionSheet cancelButtonIndex])
        {
            m_currentEndDate = nil;
        }
        else
        {
            m_currentEndDate = [m_datePicker date];
        }
    }
    [self setDateFields];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    m_datePicker = nil;
}

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
    [m_currentTextField resignFirstResponder];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view.superview isKindOfClass:[UIToolbar class]])
    {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

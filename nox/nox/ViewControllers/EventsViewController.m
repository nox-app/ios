//
//  EventsViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EventsViewController.h"

#import "CreateEventViewController.h"
#import "Event.h"
#import "EventViewController.h"
#import "MFSideMenu.h"
#import "Profile.h"
#import "SettingsViewController.h"

@interface EventsViewController ()

@end

@implementation EventsViewController

#pragma mark - Initialization

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
    [self setupNavigationBar];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.sideMenu setHidesRightSideMenu:YES];
    [m_eventsTableView reloadData];
}

- (void)setupNavigationBar
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingsPressed)];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
}

- (void)pushEventViewControllerWithEvent:(Event *)a_event
{
    EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:a_event];
    [self.navigationController pushViewController:eventViewController animated:NO];
}

#pragma mark - Button methods

- (void)settingsPressed
{
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)startEventPressed:(id)sender
{
    CreateEventViewController * createEventViewController = [[CreateEventViewController alloc] initWithDelegate:self];
    [self.navigationController presentViewController:createEventViewController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[Profile sharedProfile] events] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"Identifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    Event * event = [[[Profile sharedProfile] events] objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[event name]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_eventsTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Event * event = [[[Profile sharedProfile] events] objectAtIndex:[indexPath row]];
    EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:eventViewController animated:YES];
}


@end

//
//  EventViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EventViewController.h"

#import "CameraViewController.h"
#import "CheckInViewController.h"
#import "CommentViewController.h"
#import "Event.h"
#import "MFSideMenu.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (id)initWithEvent:(Event *)a_event
{
    if(self = [super init])
    {
        m_event = a_event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.sideMenu setHidesRightSideMenu:NO];
    [self setupNavigationBar];
    
    [m_eventLabel setText:[NSString stringWithFormat:@"I'm an event named %@!",[m_event name]]];
}

- (void)setupNavigationBar
{
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem * homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"53-house.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(homePressed)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    UIBarButtonItem * friendsMenuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered target:self.navigationController.sideMenu action:@selector(toggleRightSideMenu)];
    [self.navigationItem setRightBarButtonItem:friendsMenuButton];
}

- (void)homePressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBActions

- (IBAction)photoPressed:(id)sender
{
    CameraViewController * cameraViewController = [[CameraViewController alloc] init];
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (IBAction)checkInPressed:(id)sender
{
    CheckInViewController * checkInViewController = [[CheckInViewController alloc] init];
    [self presentViewController:checkInViewController animated:YES completion:nil];
}

- (IBAction)statusUpdatePressed:(id)sender
{
    CommentViewController * commentViewController = [[CommentViewController alloc] initWithEvent:m_event];
    [self presentViewController:commentViewController animated:YES completion:nil];
}

@end

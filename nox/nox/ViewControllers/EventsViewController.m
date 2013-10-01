//
//  EventsViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EventsViewController.h"

#import "Constants.h"
#import "Event.h"
#import "EventTableViewCell.h"
#import "EventViewController.h"
#import "FriendsMenuViewController.h"
#import "ImagePost.h"
#import "Invite.h"
#import "LoginViewController.h"
#import "MFSideMenu.h"
#import "OutlinedLabel.h"
#import "Profile.h"
#import "SettingsViewController.h"
#import "User.h"

@interface EventsViewController ()

@end

static NSString * const kEventCellReuseIdentifier = @"EventCellReuseIdentifier";

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
    
    [m_eventsTableView registerNib:[UINib nibWithNibName:@"EventTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kEventCellReuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventsDownloadFinished)
                                                 name:kEventsDownloadFinishedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventFinishedImageDownloads:) name:kEventFinishedImageDownloadsNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.menuContainerViewController setPanMode:MFSideMenuPanModeNone];
    [m_eventsTableView reloadData];
    
    //[[Profile sharedProfile] downloadEvents];
}

- (void)setupNavigationBar
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[Constants noxColor]];
    UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"19-gear.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(settingsPressed)];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
    
    //@todo(jdiprete):position this better
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UIImageView * logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [logoImageView setFrame:CGRectMake(65, 10, 70, 20)];
    [titleView addSubview:logoImageView];
    [self.navigationItem setTitleView:titleView];
    //[self setTitle:@"Nox"];
}

#pragma mark - Notifications

- (void)eventFinishedImageDownloads:(NSNotification *)a_notification
{
    Event * event = [a_notification object];
    NSUInteger index = [[[Profile sharedProfile] events] indexOfObject:event];

    if(index != NSNotFound)
    {
        [m_eventsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)eventsDownloadFinished
{
    [m_eventsTableView reloadData];
}

#pragma mark - Button methods

- (void)settingsPressed
{
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] init];
    [settingsViewController setDelegate:self];
    [self presentViewController:settingsViewController animated:YES completion:nil];
}

- (IBAction)startEventPressed:(id)sender
{
    [m_startEventSpinner startAnimating];
    [m_startEventButton setEnabled:NO];
    Event * event = [[Event alloc] init];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    NSString * dateString = [formatter stringFromDate:[NSDate date]];
    
    [event setName:dateString];
    [event setStartedAt:[NSDate date]];
    
    [[Profile sharedProfile] addEvent:event];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createdEvent:) name:kEventCreationSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventCreationFailed:) name:kEventCreationFailedNotification object:nil];
}

- (void)resetEventCreation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEventCreationSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEventCreationFailedNotification object:nil];
    [m_startEventButton setEnabled:YES];
    [m_startEventSpinner stopAnimating];
}

- (void)createdEvent:(NSNotification *)a_notification
{
    [self resetEventCreation];
    
    Event * event = [a_notification object];
    
    Invite * invite = [[Invite alloc] init];
    [invite setRsvp:YES];
    [invite setUser:[[Profile sharedProfile] user]];
    [[event invites] addObject:invite];
    
    EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:event];
    [(FriendsMenuViewController *)self.menuContainerViewController.rightMenuViewController setEvent:event];
    
    [self.navigationController pushViewController:eventViewController animated:NO];
}

- (void)eventCreationFailed:(NSNotification *)a_notification
{
    [self resetEventCreation];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to create event." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
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
    EventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kEventCellReuseIdentifier];
    if(cell == nil)
    {
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellReuseIdentifier];
    }
    
    [cell.borderBackgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cell.borderBackgroundView.layer setBorderWidth:4.0];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTap:)];
    [cell.scrollView addGestureRecognizer:tapGestureRecognizer];
    
    Event * event = [[[Profile sharedProfile] events] objectAtIndex:[indexPath row]];
    [[cell eventTitleLabel] setText:[NSString stringWithFormat:@" %@",[event name]]];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d h:mma"];
    NSString * dateString = [formatter stringFromDate:[event startedAt]];
    [[cell timeLabel] setText:[NSString stringWithFormat:@"  %@",[dateString lowercaseString]]];
    
    //In case things are reused...
    for(UIView * subview in [cell.scrollView subviews])
    {
        [subview removeFromSuperview];
    }
    
    [cell.scrollView setScrollEnabled:YES];
    [cell.scrollView setBackgroundColor:[UIColor clearColor]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if([event imagesAreDownloading])
    {
        [cell.activityIndicator startAnimating];
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell.activityIndicator stopAnimating];
        
        NSMutableArray * imagePosts = [event imagePosts];
        if([imagePosts count] == 0)
        {
//            [cell.scrollView setBackgroundColor:[Constants noxColor]];
        }
        else if([imagePosts count] == 1)
        {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.width)];
            [imageView setImage:[(ImagePost *)[imagePosts objectAtIndex:0] image]];
            [cell.scrollView addSubview:imageView];
            [cell.scrollView setScrollEnabled:NO];
            [cell.scrollView setContentSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)];
        }
        else if([imagePosts count] == 2)
        {
            UIImageView * imageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/2, cell.frame.size.width/2)];
            [imageViewLeft setImage:[(ImagePost *)[imagePosts objectAtIndex:1] image]];
            [cell.scrollView addSubview:imageViewLeft];
            
            UIImageView * imageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width/2, 0, cell.frame.size.width/2 + 1, cell.frame.size.width/2)];
            [imageViewRight setImage:[(ImagePost *)[imagePosts objectAtIndex:0] image]];
            [cell.scrollView addSubview:imageViewRight];
            [cell.scrollView setScrollEnabled:NO];
            [cell.scrollView setContentSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)];
        }
        else if([imagePosts count] > 2)
        {
            for(int i = 0; i < [imagePosts count]; i++)
            {
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*(cell.scrollView.frame.size.height), 0, cell.scrollView.frame.size.height, cell.scrollView.frame.size.height)];
                [imageView setImage:[(ImagePost *)[imagePosts objectAtIndex:[imagePosts count] - 1 - i] image]];
                [cell.scrollView addSubview:imageView];
            }
            [cell.scrollView setContentSize:CGSizeMake([imagePosts count] * cell.scrollView.frame.size.height, cell.scrollView.frame.size.height)];
        }
    }
    
    [cell.creatorImageView setHidden:YES];
    [cell.creatorImageView.layer setBorderColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor];
    [cell.creatorImageView.layer setBorderWidth:1.0];
    [cell.memberOneImageView setHidden:YES];
    [cell.memberOneImageView.layer setBorderColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor];
    [cell.memberOneImageView.layer setBorderWidth:1.0];
    [cell.memberTwoImageView setHidden:YES];
    [cell.memberTwoImageView.layer setBorderColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor];
    [cell.memberTwoImageView.layer setBorderWidth:1.0];
    [cell.ellipsisLabel setHidden:YES];
    
    //@todo(jdiprete): Invites should be returned in best friend order. Can I count on the first user being the creator? Blah do some validation...
    if([[event creator] icon])
    {
        [cell.creatorImageView setHidden:NO];
        [cell.creatorImageView setImage:[[event creator] icon]];
    }
    if([[event invites] count] > 1)
    {
        User * user = [(Invite *)[[event invites] objectAtIndex:1] user];
        if([user icon])
        {
            [cell.memberOneImageView setHidden:NO];
            [cell.memberOneImageView setImage:[user icon]];
        }
    }
    if([[event invites] count] > 2)
    {
        User * user = [(Invite *)[[event invites] objectAtIndex:2] user];
        if([user icon])
        {
            [cell.memberTwoImageView setHidden:NO];
            [cell.memberTwoImageView setImage:[user icon]];
        }
    }
    if([[event invites] count] > 3)
    {
        [cell.ellipsisLabel setHidden:NO];
    }
    
    return cell;
}

- (void)cellDidTap:(UITapGestureRecognizer *)a_gestureRecognizer
{
    for(EventTableViewCell * cell in [m_eventsTableView visibleCells])
    {
        if([[a_gestureRecognizer view] isEqual:cell.scrollView])
        {
            NSIndexPath * indexPath = [m_eventsTableView indexPathForCell:cell];
            [m_eventsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            Event * event = [[[Profile sharedProfile] events] objectAtIndex:[indexPath row]];

            [event downloadPosts];
            EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:event];
            [(FriendsMenuViewController *)self.menuContainerViewController.rightMenuViewController setEvent:event];
            [self.navigationController pushViewController:eventViewController animated:YES];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EventTableViewCell height];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_eventsTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Event * event = [[[Profile sharedProfile] events] objectAtIndex:[indexPath row]];
    EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:event];
    [(FriendsMenuViewController *)self.menuContainerViewController.rightMenuViewController setEvent:event];
    [self.navigationController pushViewController:eventViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SettingsViewControllerDelegate Methods

- (void)logoutFromSettings
{
    [self dismissViewControllerAnimated:NO completion:^(void)
     {
         LoginViewController * loginViewController = [[LoginViewController alloc] init];
         [self.navigationController presentViewController:loginViewController animated:NO completion:nil];
     }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

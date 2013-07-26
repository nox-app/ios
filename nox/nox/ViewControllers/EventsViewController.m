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
#import "MFSideMenu.h"
#import "OutlinedLabel.h"
#import "Profile.h"
#import "SettingsViewController.h"

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
    
    //@todo(jdiprete):position this better
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UIImageView * logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [logoImageView setFrame:CGRectMake(55, 5, 90, 30)];
    [titleView addSubview:logoImageView];
    [self.navigationItem setTitleView:titleView];
}

#pragma mark - Notifications

- (void)eventsDownloadFinished
{
    [m_eventsTableView reloadData];
}

#pragma mark - Button methods

- (void)settingsPressed
{
    SettingsViewController * settingsViewController = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)startEventPressed:(id)sender
{
    Event * event = [[Event alloc] init];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    NSString * dateString = [formatter stringFromDate:[NSDate date]];
    
    [event setName:dateString];
    [event setStartedAt:[NSDate date]];
    
    NSDate * endDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [event setEndedAt:endDate]; //@todo(jdiprete): should we auto have an end date? or make it ongoing?
    
    [[Profile sharedProfile] addEvent:event];
    
    EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:event];
    [self.navigationController pushViewController:eventViewController animated:NO];
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
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellDidTap:)];
    [cell.scrollView addGestureRecognizer:tapGestureRecognizer];
    
    Event * event = [[[Profile sharedProfile] events] objectAtIndex:[indexPath row]];
    [[cell eventTitleLabel] setText:[event name]];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d h:mma"];
    NSString * dateString = [formatter stringFromDate:[event startedAt]];
    [[cell timeLabel] setText:[dateString lowercaseString]];
    
    //In case things are reused...
    for(UIView * subview in [cell.scrollView subviews])
    {
        [subview removeFromSuperview];
    }
    
    NSMutableArray * images = [event images];
    if([images count] == 1)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width + 1, cell.frame.size.width)];
        [imageView setImage:[images objectAtIndex:0]];
        [cell.scrollView addSubview:imageView];
        [cell.scrollView setContentSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)];
    }
    else if([images count] == 2)
    {
        UIImageView * imageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/2, cell.frame.size.width/2)];
        [imageViewLeft setImage:[images objectAtIndex:1]];
        [cell.scrollView addSubview:imageViewLeft];
        
        UIImageView * imageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width/2, 0, cell.frame.size.width/2 + 1, cell.frame.size.width/2)];
        [imageViewRight setImage:[images objectAtIndex:0]];
        [cell.scrollView addSubview:imageViewRight];
        [cell.scrollView setContentSize:CGSizeMake(cell.frame.size.width, cell.frame.size.height)];
    }
    else if([images count] > 2)
    {
        for(int i = 0; i < [images count]; i++)
        {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*(cell.frame.size.height), 0, cell.frame.size.height, cell.frame.size.height)];
            [imageView setImage:[images objectAtIndex:[images count] - 1 - i]];
            [cell.scrollView addSubview:imageView];
        }
        [cell.scrollView setContentSize:CGSizeMake([images count] * cell.frame.size.height, cell.scrollView.frame.size.height)];
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
            EventViewController * eventViewController = [[EventViewController alloc] initWithEvent:event];
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
    [self.navigationController pushViewController:eventViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

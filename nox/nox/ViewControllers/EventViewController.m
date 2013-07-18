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
#import "ImagePost.h"
#import "ImagePostTableViewCell.h"
#import "MFSideMenu.h"
#import "PlacePost.h"
#import "PlacePostTableViewCell.h"
#import "Post.h"
#import "TextPost.h"
#import "TextPostTableViewCell.h"

@interface EventViewController ()

@end

static NSString * const kTextPostCellReuseIdentifier = @"TextPostCellReuseIdentifier";
static NSString * const kImagePostCellReuseIdentifier = @"ImagePostCellReuseIdentifier";
static NSString * const kPlacePostCellReuseIdentifier = @"PlacePostCellReuseIdentifier";

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
    
    [m_tableView registerNib:[UINib nibWithNibName:@"TextPostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kTextPostCellReuseIdentifier];
    [m_tableView registerNib:[UINib nibWithNibName:@"ImagePostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kImagePostCellReuseIdentifier];
    [m_tableView registerNib:[UINib nibWithNibName:@"PlacePostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kPlacePostCellReuseIdentifier];
    
    [self.navigationController.sideMenu setHidesRightSideMenu:NO];
    [self setupNavigationBar];
    [self setTitle:[m_event name]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [m_tableView reloadData];
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

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[m_event posts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostType type = [(Post *)[[m_event posts] objectAtIndex:indexPath.row] type];
    
    if(type == kImageType)
    {
        ImagePost * post = [[m_event posts] objectAtIndex:indexPath.row];
        
        ImagePostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kImagePostCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[ImagePostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kImagePostCellReuseIdentifier];
        }
        
        [cell.postImageView setImage:[post image]];
        [cell.captionTextView setText:[post caption]];
        
        return cell;
        
    }
    else if(type == kTextType)
    {
        TextPost * post = [[m_event posts] objectAtIndex:indexPath.row];
        
        TextPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kTextPostCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[TextPostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextPostCellReuseIdentifier];
        }
        
        [cell.textView setText:[post body]];
        
        return cell;
    }
    else //type is place
    {
        PlacePost * post = [[m_event posts] objectAtIndex:indexPath.row];
        
        PlacePostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kPlacePostCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[PlacePostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlacePostCellReuseIdentifier];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostType type = [(Post *)[[m_event posts] objectAtIndex:indexPath.row] type];
    switch(type)
    {
        case kTextType:
            return [TextPostTableViewCell height];
            break;
        case kImageType:
            return [ImagePostTableViewCell height];
            break;
        case kPlaceType:
            return [PlacePostTableViewCell height];
            break;
        default:
            break;
    }
}

#pragma mark - IBActions

- (IBAction)photoPressed:(id)sender
{
    CameraViewController * cameraViewController = [[CameraViewController alloc] initWithEvent:m_event];
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (IBAction)checkInPressed:(id)sender
{
    CheckInViewController * checkInViewController = [[CheckInViewController alloc] initWithEvent:m_event];
    [self presentViewController:checkInViewController animated:YES completion:nil];
}

- (IBAction)statusUpdatePressed:(id)sender
{
    CommentViewController * commentViewController = [[CommentViewController alloc] initWithEvent:m_event];
    [self presentViewController:commentViewController animated:YES completion:nil];
}

@end

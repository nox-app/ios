//
//  FriendsMenuViewController.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "FriendsMenuViewController.h"

#import "Contact.h"
#import "Event.h"
#import "EventMemberTableViewCell.h"
#import "Invite.h"
#import "InviteContactTableViewCell.h"
#import "InviteUserTableViewCell.h"
#import "MFSideMenu.h"
#import "Profile.h"
#import "User.h"

static NSString * const kInviteUserTableViewCellReuseIdentifier = @"InviteUserTableViewCellReuseIdentifier";
static NSString * const kInviteContactTableViewCellReuseIdentifier = @"InviteContactTableViewCellReuseIdentifier";
static NSString * const kEventMemberTableViewCellReuseIdentifier = @"EventMemberTableViewCellReuseIdentifier";

@interface FriendsMenuViewController ()

@end

@implementation FriendsMenuViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsDidFilter) name:kContactFilterDidFinishNotification object:nil];
    
    m_inviteContactsArray = [NSMutableArray arrayWithArray:[[Profile sharedProfile] contacts]];
    m_inviteUsersArray = [NSMutableArray arrayWithArray:[[Profile sharedProfile] userFriends]];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    [m_inviteTableView registerNib:[UINib nibWithNibName:@"InviteUserTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kInviteUserTableViewCellReuseIdentifier];
    [m_inviteTableView registerNib:[UINib nibWithNibName:@"InviteContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kInviteContactTableViewCellReuseIdentifier];
    [m_membersTableView registerNib:[UINib nibWithNibName:@"EventMemberTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kEventMemberTableViewCellReuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteUserDidSucceed) name:kInviteDidSucceedNotification object:nil];
}

- (void)inviteUserDidSucceed
{
    [self resetUserInviteArray];
    [m_membersTableView reloadData];
    [m_inviteTableView reloadData];
}

- (void)menuStateEventOccurred:(NSNotification *)a_notification
{
    MFSideMenuStateEvent event = [[[a_notification userInfo] objectForKey:@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuWillClose)
    {
        [m_searchBar resignFirstResponder];
    }
}

- (void)resetUserInviteArray
{
    m_originalInviteUsersArray = [NSMutableArray arrayWithArray:[[Profile sharedProfile] userFriends]];
    for(Invite * invite in [m_event invites])
    {
        [m_originalInviteUsersArray removeObject:[invite user]];
    }
    m_inviteUsersArray = [NSMutableArray arrayWithArray:m_originalInviteUsersArray];
}

- (void)setEvent:(Event *)a_event
{
    m_event = a_event;
    [self resetUserInviteArray];
    [m_membersTableView reloadData];
    [m_inviteTableView reloadData];
}
     
- (void)contactsDidFilter
{
    [m_inviteTableView reloadData];
}

- (void)inviteButtonPressed:(id)a_sender
{
    CGPoint buttonOriginInTableView = [a_sender convertPoint:CGPointZero toView:m_inviteTableView];
    NSIndexPath * indexPath = [m_inviteTableView indexPathForRowAtPoint:buttonOriginInTableView];
    m_currentInvitationUser = [m_inviteUsersArray objectAtIndex:indexPath.row];
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Invitation", [m_event name]] message:[NSString stringWithFormat:@"Invite %@ as a...", [m_currentInvitationUser firstName]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Member", @"Viewer", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [m_event inviteUser:m_currentInvitationUser withRSVP:YES];
    } else if(buttonIndex == 2)
    {
        [m_event inviteUser:m_currentInvitationUser withRSVP:NO];
    }
    m_currentInvitationUser = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if([tableView isEqual:m_membersTableView])
    {
        return 1;
    }
    else if([tableView isEqual:m_inviteTableView])
    {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([tableView isEqual:m_membersTableView])
    {
        return [[m_event invites] count];
    }
    else if([tableView isEqual:m_inviteTableView])
    {
        if(section == 0)
        {
            return [m_inviteUsersArray count];
        }
        else
        {
            return [m_inviteContactsArray count];
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:m_membersTableView])
    {
        EventMemberTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kEventMemberTableViewCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[EventMemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventMemberTableViewCellReuseIdentifier];
        }
        Invite * invite = [[m_event invites] objectAtIndex:indexPath.row];
        NSString * userName = [NSString stringWithFormat:@"%@ %@",[[invite user] firstName], [[invite user] lastName]];
        cell.nameLabel.text = userName;
        
        [cell.userIcon setImage:[[invite user] icon]];
        if([[invite user] id] == [[m_event creator] id])
        {
            NSLog(@"USER ID: %d CREATOR ID: %d", [[invite user] id], [[m_event creator] id]);
            [cell.rsvpIcon setImage:[UIImage imageNamed:@"creatorIcon.png"]];
        }
        else if([invite rsvp])
        {
            [cell.rsvpIcon setImage:[UIImage imageNamed:@"memberIcon.png"]];
        }
        else
        {
            [cell.rsvpIcon setImage:[UIImage imageNamed:@"viewIcon.png"]];
        }
        return cell;
    }
    else
    {
        if(indexPath.section == 0)
        {
            InviteUserTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kInviteUserTableViewCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[InviteUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInviteUserTableViewCellReuseIdentifier];
            }
            
            User * user = [m_inviteUsersArray objectAtIndex:indexPath.row];
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
            [cell.userIcon setImage:[user icon]];
            [cell.inviteButton addTarget:self action:@selector(inviteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        else
        {
            InviteContactTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kInviteContactTableViewCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[InviteContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kInviteContactTableViewCellReuseIdentifier];
            }
            Contact * contact = [m_inviteContactsArray objectAtIndex:indexPath.row];
            cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName ? contact.firstName:@"", contact.lastName ? contact.lastName:@""];
            return cell;
        }
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_searchBar resignFirstResponder];
    [self.menuContainerViewController toggleRightSideMenuCompletion:^(void)
     {
         
     }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Search Text: %@", searchText);
    if([searchText length] == 0)
    {
        m_inviteContactsArray = [NSMutableArray arrayWithArray:[[Profile sharedProfile] contacts]];
        m_inviteUsersArray = [NSMutableArray arrayWithArray:m_originalInviteUsersArray];
    }
    else
    {
        NSArray * oldInviteContactsArray;
        NSArray * oldInviteUserArray;
        if([m_lastSearchQuery length] > [searchText length])
        {
            oldInviteContactsArray = [NSArray arrayWithArray:[[Profile sharedProfile] contacts]];
            oldInviteUserArray = m_originalInviteUsersArray;
        }
        else
        {
            oldInviteContactsArray = [NSArray arrayWithArray:m_inviteContactsArray];
            oldInviteUserArray = [NSArray arrayWithArray:m_inviteUsersArray];
        }
        [m_inviteContactsArray removeAllObjects];
        [m_inviteUsersArray removeAllObjects];
        for(Contact * contact in oldInviteContactsArray)
        {
            NSString * name = [[NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName] lowercaseString];
            if([name rangeOfString:[searchText lowercaseString]].location != NSNotFound)
            {
                NSLog(@"Adding Contact: %@", name);
                [m_inviteContactsArray addObject:contact];
            }
        }
        for(User * user in oldInviteUserArray)
        {
            NSString * name = [[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName] lowercaseString];
            if([name rangeOfString:[searchText lowercaseString]].location != NSNotFound)
            {
                NSLog(@"Adding User: %@", name);
                [m_inviteUsersArray addObject:user];
            }
        }
    }
    m_lastSearchQuery = searchText;
    [m_inviteTableView reloadData];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{

}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)dismissKeyboard
{
    [m_searchBar resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)a_notification
{
    if([m_searchBar isFirstResponder])
    {
        NSDictionary * keyboardInfo = [a_notification userInfo];
        NSValue * keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(self.view.frame.origin.x, -keyboardFrameBeginRect.size.height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)a_notification
{
    if([m_searchBar isFirstResponder])
    {
        [UIView animateWithDuration:0.1f animations:^ {
            self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

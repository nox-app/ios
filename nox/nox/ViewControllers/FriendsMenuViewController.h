//
//  FriendsMenuViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@class User;

@interface FriendsMenuViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    IBOutlet UISearchBar * m_searchBar;
    IBOutlet UITableView * m_membersTableView;
    IBOutlet UITableView * m_inviteTableView;
    
    NSString * m_lastSearchQuery;
    
    NSMutableArray * m_originalInviteUsersArray;
    NSMutableArray * m_inviteUsersArray;
    NSMutableArray * m_inviteContactsArray;
    
    Event * m_event;
    User * m_currentInvitationUser;
}

- (void)setEvent:(Event *)a_event;

@end

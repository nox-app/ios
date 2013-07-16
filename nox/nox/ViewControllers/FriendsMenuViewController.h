//
//  FriendsMenuViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFSideMenu;

@interface FriendsMenuViewController : UIViewController
{
    IBOutlet UISearchBar * m_searchBar;
    IBOutlet UITableView * m_tableView;
}

@property (nonatomic, assign) MFSideMenu * sideMenu;

@end

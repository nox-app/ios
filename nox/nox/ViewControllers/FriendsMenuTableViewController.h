//
//  FriendsMenuTableViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/1/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFSideMenu;

@interface FriendsMenuTableViewController : UITableViewController 
{
    UISearchBar * m_searchBar;
}

@property (nonatomic, assign) MFSideMenu * sideMenu;

@end

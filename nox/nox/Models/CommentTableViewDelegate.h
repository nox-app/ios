//
//  CommentTableViewDelegate.h
//  nox
//
//  Created by Justine DiPrete on 8/16/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;

@interface CommentTableViewDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>
{
    Post * m_post;
    UITableView * m_tableView;
}

@property Post * post;

- (id)initWithTableView:(UITableView *)a_tableView;

@end

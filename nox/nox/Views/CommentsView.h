//
//  CommentsView.h
//  nox
//
//  Created by Justine DiPrete on 7/23/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommentsViewDelegate.h"

extern float kCommentViewHeight;

@class Post;

@interface CommentsView : UIView
{
    UIView * m_view;
    Post * m_post;
    
    id<CommentsViewDelegate> m_delegate;
}

@property Post * post;
@property IBOutlet UIView * view;
@property IBOutlet UILabel * likeNumberLabel;
@property IBOutlet UILabel * dislikeNumberLabel;
@property IBOutlet UIButton * commentsButton;
@property IBOutlet UIButton * likeButton;
@property IBOutlet UIButton * dislikeButton;
@property IBOutlet UITableView * commentTableView;
@property id<CommentsViewDelegate> delegate;

- (IBAction)expandCommentsPressed:(id)sender;
- (IBAction)likePressed:(id)sender;
- (IBAction)dislikePressed:(id)sender;


@end

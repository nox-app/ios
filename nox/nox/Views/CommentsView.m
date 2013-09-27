//
//  CommentsView.m
//  nox
//
//  Created by Justine DiPrete on 7/23/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CommentsView.h"

#import "Comment.h"
#import "CommentTableViewCell.h"
#import "Post.h"

float kCommentViewHeight = 40.0;

@implementation CommentsView

@synthesize view = m_view;
@synthesize post = m_post;
@synthesize delegate = m_delegate;

#pragma mark - Initialization

- (id)init
{
    if(self = [super init])
    {
        [[NSBundle mainBundle] loadNibNamed:@"CommentsView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSBundle mainBundle] loadNibNamed:@"CommentsView" owner:self options:nil];
    [self addSubview:self.view];
}

#pragma mark - IBActions

- (IBAction)expandCommentsPressed:(id)sender
{
    [m_delegate expandCommentsPressedForPost:m_post];
}

- (IBAction)likePressed:(id)sender
{
    [m_delegate likePressedForPost:m_post];
}

- (IBAction)dislikePressed:(id)sender
{
    [m_delegate dislikePressedForPost:m_post];
}

@end

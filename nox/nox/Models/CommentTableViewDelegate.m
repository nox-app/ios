//
//  CommentTableViewDelegate.m
//  nox
//
//  Created by Justine DiPrete on 8/16/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CommentTableViewDelegate.h"

#import "Comment.h"
#import "CommentTableViewCell.h"
#import "Post.h"
#import "User.h"
#import "Util.h"

static NSString * const kCommentCellReuseIdentifier = @"CommentCellReuseIdentifier";

static const int kCommentTextViewTag = 1;

static const int kCommentTextViewOffset = 20;

@implementation CommentTableViewDelegate

@synthesize post = m_post;

- (id)initWithTableView:(UITableView *)a_tableView
{
    if(self = [super init])
    {
        m_tableView = a_tableView;
        [m_tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCommentCellReuseIdentifier];
    }
    return self;
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
    return [[m_post comments] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment * comment = [[m_post comments] objectAtIndex:indexPath.row];
    
    CommentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellReuseIdentifier];
    if(cell == nil)
    {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCommentCellReuseIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [(UITextView *)[cell viewWithTag:kCommentTextViewTag] removeFromSuperview];
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(50, 25, 250, 30)];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setScrollEnabled:NO];
    [textView setEditable:NO];
    [textView setFont:[UIFont systemFontOfSize:14]];
    [cell.contentView addSubview:textView];
    [textView setTag:kCommentTextViewTag];
    
    [textView setText:[comment body]];
    
    CGSize commentSize = [[comment body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(250, 999)];
    int heightDifference = 0;
    if(commentSize.height > 30)
    {
        heightDifference = commentSize.height - 30 + kCommentTextViewOffset;
    }
    
    CGRect textViewFrame = textView.frame;
    textViewFrame.size.height += heightDifference;
    [textView setFrame:textViewFrame];
    

    [[cell timeLabel] setText:[Util stringFromDate:[comment time]]];
    if([comment user].firstName != nil)
    {
        [[cell userName] setText:[NSString stringWithFormat:@"%@ %@", [comment user].firstName, [comment user].lastName]];
    }
    else
    {
        [[cell userName] setText:@""];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment * comment = [[m_post comments] objectAtIndex:indexPath.row];
    CGSize commentSize = [[comment body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(222, 999)];
    int heightDifference = 0;
    if(commentSize.height > 30)
    {
        heightDifference = commentSize.height - 30 + kCommentTextViewOffset;
    }
    return [CommentTableViewCell height] + heightDifference;
}

@end

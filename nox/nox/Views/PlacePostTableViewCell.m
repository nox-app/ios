//
//  PlacePostTableViewCell.m
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "PlacePostTableViewCell.h"

#import "CommentsView.h"
#import "FirstCommentView.h"

@implementation PlacePostTableViewCell

@synthesize showsFirstComment = m_showsFirstComment;
@synthesize firstCommentView = m_firstCommentView;
@synthesize commentsView = m_commentsView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(m_showsFirstComment)
    {
        [m_firstCommentView setHidden:NO];
//        [m_firstCommentView setFrame:CGRectMake(0, [PlacePostTableViewCell height], self.frame.size.width, kFirstCommentHeight)];
//        [m_commentsView setFrame:CGRectMake(0, [PlacePostTableViewCell height] + kFirstCommentHeight, self.frame.size.width, kCommentViewBaseHeight)];
    }
    else
    {
        [m_firstCommentView setHidden:YES];
//        [m_commentsView setFrame:CGRectMake(0, [PlacePostTableViewCell height], self.frame.size.width, kCommentViewBaseHeight)];
    }
}

+ (CGFloat)height
{
    return 230;
}

@end

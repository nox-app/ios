//
//  PlacePostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentsView;
@class FirstCommentView;

@interface PlacePostTableViewCell : UITableViewCell
{
    BOOL m_showsFirstComment;
    FirstCommentView * m_firstCommentView;
    CommentsView * m_commentsView;
}

@property IBOutlet UIImageView * iconImageView;
@property IBOutlet UILabel * placeNameLabel;
@property IBOutlet UILabel * cityStateLabel;
@property IBOutlet UILabel * timeLabel;
@property IBOutlet UIView * backgroundBorderView;
@property IBOutlet CommentsView * commentsView;
@property IBOutlet FirstCommentView * firstCommentView;
@property BOOL showsFirstComment;

+ (CGFloat)height;

@end

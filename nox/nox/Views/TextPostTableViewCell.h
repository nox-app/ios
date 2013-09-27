//
//  TextPostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentsView;
@class FirstCommentView;

@interface TextPostTableViewCell : UITableViewCell
{
    UITextView * m_textView;
}

@property IBOutlet UIImageView * userPicture;
@property IBOutlet UILabel * userName;
@property IBOutlet UILabel * timeLabel;

+ (CGFloat)height;

@end

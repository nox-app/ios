//
//  ImagePostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentsView;
@class FirstCommentView;

@interface ImagePostTableViewCell : UITableViewCell

@property IBOutlet UIImageView * userPicture;
@property IBOutlet UILabel * userName;
@property IBOutlet UIImageView * postImageView;
@property IBOutlet UILabel * timeLabel;
@property IBOutlet UIActivityIndicatorView * activityIndicator;

+ (CGFloat)height;

@end

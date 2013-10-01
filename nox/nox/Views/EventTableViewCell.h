//
//  EventTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OutlinedLabel;

@interface EventTableViewCell : UITableViewCell

@property IBOutlet OutlinedLabel * eventTitleLabel;
@property IBOutlet OutlinedLabel * timeLabel;
@property IBOutlet UIScrollView * scrollView;
@property IBOutlet UIActivityIndicatorView * activityIndicator;
@property IBOutlet UIView * borderBackgroundView;
@property IBOutlet UIImageView * creatorImageView;
@property IBOutlet UIImageView * memberOneImageView;
@property IBOutlet UIImageView * memberTwoImageView;
@property IBOutlet UILabel * ellipsisLabel;

+ (CGFloat)height;

@end

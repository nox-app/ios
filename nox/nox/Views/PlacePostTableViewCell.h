//
//  PlacePostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacePostTableViewCell : UITableViewCell

@property IBOutlet UIImageView * iconImageView;
@property IBOutlet UILabel * placeNameLabel;
@property IBOutlet UILabel * cityStateLabel;
@property IBOutlet UILabel * timeLabel;
@property IBOutlet UIView * backgroundBorderView;
@property IBOutlet UIView * commentsView;

+ (CGFloat)height;

@end

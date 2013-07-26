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

+ (CGFloat)height;

@end

//
//  EventDetailsTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 9/14/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsTableViewCell : UITableViewCell

@property IBOutlet UILabel * titleLabel;
@property IBOutlet UILabel * startLabel;
@property IBOutlet UILabel * endLabel;
@property IBOutlet UILabel * locationLabel;
@property IBOutlet UIView * borderView;
@property IBOutlet UIButton * editButton;

+ (CGFloat)height;

@end

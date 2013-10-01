//
//  VenueTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 10/1/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueTableViewCell : UITableViewCell

@property IBOutlet UIImageView * icon;
@property IBOutlet UILabel * nameLabel;
@property IBOutlet UILabel * distanceLabel;
@property IBOutlet UILabel * addressLabel;

+ (CGFloat)height;

@end

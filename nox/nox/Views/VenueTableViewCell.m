//
//  VenueTableViewCell.m
//  nox
//
//  Created by Justine DiPrete on 10/1/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "VenueTableViewCell.h"

@implementation VenueTableViewCell

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

+ (CGFloat)height
{
    return 72.0;
}

@end

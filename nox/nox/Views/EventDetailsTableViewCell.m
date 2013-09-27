//
//  EventDetailsTableViewCell.m
//  nox
//
//  Created by Justine DiPrete on 9/14/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EventDetailsTableViewCell.h"

@implementation EventDetailsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NSLog(@"Here?");
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
    return 240;
}

@end

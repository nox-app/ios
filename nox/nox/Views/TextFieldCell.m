//
//  TextFieldCell.m
//  nox
//
//  Created by Justine DiPrete on 8/19/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell

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
    //return the height of the cell
    return 44;
}

@end

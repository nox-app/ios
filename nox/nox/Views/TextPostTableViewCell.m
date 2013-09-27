//
//  TextPostTableViewCell.m
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "TextPostTableViewCell.h"

#import "CommentsView.h"
#import "FirstCommentView.h"

@implementation TextPostTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)height
{
    return 120;
}

@end

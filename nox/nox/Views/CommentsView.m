//
//  CommentsView.m
//  nox
//
//  Created by Justine DiPrete on 7/23/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CommentsView.h"

@implementation CommentsView

@synthesize view = m_view;

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        // Initialization code.
        [[NSBundle mainBundle] loadNibNamed:@"CommentsView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubview:self.view];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

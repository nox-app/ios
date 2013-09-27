//
//  FirstCommentView.m
//  nox
//
//  Created by Justine DiPrete on 8/22/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "FirstCommentView.h"

float kFirstCommentHeight = 60.0;
float kFirstCommentTextViewOffset = 20.0;

@implementation FirstCommentView

@synthesize view = m_view;

- (id)init
{
    if(self = [super init])
    {
        [[NSBundle mainBundle] loadNibNamed:@"FirstCommentView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSBundle mainBundle] loadNibNamed:@"FirstCommentView" owner:self options:nil];
    [self addSubview:self.view];
}

+ (CGRect)textViewBaseFrame
{
    return CGRectMake(48, 25, 266, 30);
}

@end

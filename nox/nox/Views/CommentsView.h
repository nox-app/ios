//
//  CommentsView.h
//  nox
//
//  Created by Justine DiPrete on 7/23/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsView : UIView
{
    UIView * m_view;
}

@property IBOutlet UIView * view;
@property IBOutlet UILabel * likeNumberLabel;
@property IBOutlet UILabel * dislikeNumberLabel;
@property IBOutlet UILabel * commentNumberLabel;

@end

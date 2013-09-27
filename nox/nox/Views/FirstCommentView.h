//
//  FirstCommentView.h
//  nox
//
//  Created by Justine DiPrete on 8/22/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

extern float kFirstCommentHeight;
extern float kFirstCommentTextViewOffset;

@interface FirstCommentView : UIView
{
    UIView * m_view;
}

@property IBOutlet UIView * view;
@property IBOutlet UIView * firstCommentView;
@property IBOutlet UIImageView * userPicture;
@property IBOutlet UILabel * userName;
@property IBOutlet UILabel * timeLabel;

+ (CGRect)textViewBaseFrame;

@end

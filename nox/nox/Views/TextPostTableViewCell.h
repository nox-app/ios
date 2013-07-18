//
//  TextPostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextPostTableViewCell : UITableViewCell
{
    UITextView * m_textView;
}

@property IBOutlet UIImageView * userPicture;
@property IBOutlet UILabel * userName;
@property IBOutlet UITextView * textView;

+ (CGFloat)height;

@end

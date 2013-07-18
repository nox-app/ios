//
//  ImagePostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePostTableViewCell : UITableViewCell

@property IBOutlet UIImageView * userPicture;
@property IBOutlet UILabel * userName;
@property IBOutlet UIImageView * postImageView;
@property IBOutlet UITextView * captionTextView;


+ (CGFloat)height;

@end

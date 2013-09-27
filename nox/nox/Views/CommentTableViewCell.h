//
//  CommentTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 8/8/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property IBOutlet UIImageView * userPicture;
@property IBOutlet UILabel * userName;
@property IBOutlet UILabel * timeLabel;

+ (CGFloat)height;

@end

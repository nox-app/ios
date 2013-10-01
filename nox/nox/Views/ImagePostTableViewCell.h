//
//  ImagePostTableViewCell.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PostTableViewCell.h"

@class CommentsView;
@class FirstCommentView;

@interface ImagePostTableViewCell : PostTableViewCell

@property IBOutlet UIImageView * postImageView;
@property IBOutlet UIActivityIndicatorView * activityIndicator;

@end

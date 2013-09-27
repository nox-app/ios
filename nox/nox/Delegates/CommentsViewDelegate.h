//
//  CommentsViewDelegate.h
//  nox
//
//  Created by Justine DiPrete on 9/4/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Post;

@protocol CommentsViewDelegate <NSObject>

- (void)expandCommentsPressedForPost:(Post *)a_post;
- (void)likePressedForPost:(Post *)a_post;
- (void)dislikePressedForPost:(Post *)a_post;

@end

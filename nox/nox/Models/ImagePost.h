//
//  ImagePost.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Post.h"

@interface ImagePost : Post
{
    NSString * m_caption;
    UIImage * m_image;
}

@property NSString * caption;
@property UIImage * image;

@end

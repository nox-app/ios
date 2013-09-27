//
//  ImagePost.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Post.h"

extern NSString * const kImagePostDidDownloadNotification;

@interface ImagePost : Post
{
    NSString * m_caption;
    UIImage * m_image;
    
    NSString * m_imageURL;
    
    BOOL m_imageIsDownloading;
}

@property UIImage * image;
@property BOOL imageIsDownloading;

- (void)downloadImage;

@end

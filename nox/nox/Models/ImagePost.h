//
//  ImagePost.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Post.h"

extern NSString * const kImagePostDownloadDidSucceedNotification;
extern NSString * const kImagePostDownloadDidFailNotification;

@interface ImagePost : Post <NSURLConnectionDelegate>
{
    NSString * m_caption;
    UIImage * m_image;
    
    NSString * m_imageURL;
    
    BOOL m_imageIsDownloading;
    
    NSMutableData * m_imageDownloadBuffer;
}

@property UIImage * image;
@property BOOL imageIsDownloading;

- (void)downloadImage;

@end

//
//  PictureEditView.h
//  nox
//
//  Created by Justine DiPrete on 7/17/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureEditView : UIView
{
    UIImageView * m_imageView;
    UIImage * m_image;
}

- (void)setImage:(UIImage *)a_image;

@end

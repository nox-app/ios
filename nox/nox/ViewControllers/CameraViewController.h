//
//  CameraViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@class ImagePost;
@class PictureEditView;
@class UIPlaceHolderTextView;

@interface CameraViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextViewDelegate>
{
    IBOutlet UIView * m_cameraOverlayView;
    
    IBOutlet UIScrollView * m_photoScrollView;
    IBOutlet UIView * m_photoView;
    IBOutlet UIImageView * m_editImageView;
    IBOutlet UIPlaceHolderTextView * m_editCaptionTextView;
    
    PictureEditView * m_pictureEditView;
    
    NSMutableArray * m_photoArray;
    NSMutableArray * m_imagePostArray;
    
    Event * m_event;
    
    ImagePost * m_currentImagePost;
}

- (id)initWithEvent:(Event *)a_event;

- (IBAction)cameraDonePressed:(id)sender;
- (IBAction)takePicturePressed:(id)sender;

- (IBAction)cancelPictureEditPressed:(id)sender;
- (IBAction)savePictureEditPressed:(id)sender;

- (IBAction)postPressed:(id)sender;

@end

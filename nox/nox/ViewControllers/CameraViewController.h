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
@class UIPlaceHolderTextView;

@interface CameraViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIView * m_cameraOverlayView;
    
    IBOutlet UIScrollView * m_photoScrollView;
    IBOutlet UIView * m_photoView;
    
    NSMutableArray * m_photoArray;
    NSMutableArray * m_imagePostArray;
    
    Event * m_event;
    ImagePost * m_currentImagePost;
    
    float m_pictureDragY;
    
    IBOutlet UIView * m_pictureDetailView;
    IBOutlet UIImageView * m_pictureImageView;
    IBOutlet UIButton * m_cameraButton;
    IBOutlet UIButton * m_postButton;
    
    IBOutlet UIButton * m_flashButton;
    UIImagePickerControllerCameraFlashMode m_flashMode;
}

- (id)initWithEvent:(Event *)a_event;

- (IBAction)cameraDonePressed:(id)sender;
- (IBAction)takePicturePressed:(id)sender;

- (IBAction)postPressed:(id)sender;
- (IBAction)switchCameraViewPressed:(id)sender;
- (IBAction)switchToCameraPressed:(id)sender;
- (IBAction)toggleFlash:(id)sender;

@end

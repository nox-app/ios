//
//  CameraViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface CameraViewController : UIImagePickerController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIView * m_cameraOverlayView;
    
    IBOutlet UIScrollView * m_photoScrollView;
    IBOutlet UIView * m_photoView;
    
    NSMutableArray * m_photoArray;
    
    Event * m_event;
}

- (id)initWithEvent:(Event *)a_event;

- (IBAction)cameraDonePressed:(id)sender;
- (IBAction)takePicturePressed:(id)sender;

@end

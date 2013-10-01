//
//  ProfileCameraViewController.h
//  nox
//
//  Created by Justine DiPrete on 9/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProfileCameraViewControllerDelegate.h"

@interface ProfileCameraViewController : UIImagePickerController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage * m_currentPicture;
    
    IBOutlet UIButton * m_flashButton;
    IBOutlet UIImageView * m_profileImageView;
    IBOutlet UIView * m_previewView;
    
    UIImagePickerControllerCameraFlashMode m_flashMode;
    
    id<ProfileCameraViewControllerDelegate> m_profileDelegate;
}

@property id<ProfileCameraViewControllerDelegate> profileDelegate;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)toggleFlash:(id)sender;
- (IBAction)switchCameraViewPressed:(id)sender;
- (IBAction)usePicturePressed:(id)sender;
- (IBAction)retakePicturePressed:(id)sender;

@end

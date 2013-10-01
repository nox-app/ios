//
//  EditProfileViewController.h
//  nox
//
//  Created by Justine DiPrete on 9/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProfileCameraViewControllerDelegate.h"

@interface EditProfileViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProfileCameraViewControllerDelegate>
{
    IBOutlet UIImageView * m_iconView;
}

- (IBAction)donePressed:(id)sender;
- (IBAction)editIconPressed:(id)sender;

@end

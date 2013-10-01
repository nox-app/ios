//
//  SignUpViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProfileCameraViewControllerDelegate.h"

@class User;

typedef enum SignUpField
{
    kSignUpNameField = 0,
    kSignUpEmailField,
    kSignUpPhoneNumberField,
    kSignUpBirthdayField,
    kSignUpPasswordField
} SignUpField;

@interface SignUpViewController : UIViewController<UIActionSheetDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ProfileCameraViewControllerDelegate>
{
    IBOutlet UITableView * m_tableView;
    NSArray * m_placeHolderTextArray;
    NSArray * m_namePlaceHolderArray;
    UITextField * m_currentFirstResponder;
    UITableView * m_nameTableView;
    
    UIImage * m_profilePicture;
    
    User * m_user;
}

- (IBAction)cancelPressed:(id)sender;
- (IBAction)signUpPressed:(id)sender;

@end

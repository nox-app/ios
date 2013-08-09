//
//  LoginViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UITextField * m_emailTextField;
    IBOutlet UITextField * m_passwordTextField;
    
    NSMutableData * m_downloadBuffer;
    
    NSString * m_email;
    BOOL m_success;
}

- (IBAction)loginPressed:(id)sender;

@end

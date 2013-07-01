//
//  LoginViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
{
    IBOutlet UITextField * m_emailTextField;
    IBOutlet UITextField * m_passwordTextField;
}

- (IBAction)loginPressed:(id)sender;

@end

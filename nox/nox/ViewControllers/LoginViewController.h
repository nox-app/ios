//
//  LoginViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

typedef enum LoginField
{
    kLoginEmailField = 0,
    kLoginPasswordField
} LoginField;

@interface LoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ASIHTTPRequestDelegate>
{
    IBOutlet UITableView * m_tableView;
    
    NSArray * m_loginPlaceholderArray;
    UITextField * m_currentFirstResponder;
    
    NSMutableData * m_downloadBuffer;
    
    NSString * m_email;
    BOOL m_success;
    
    LoginField m_selectedLoginField;
}

- (IBAction)loginPressed:(id)sender;
- (IBAction)signUpPressed:(id)sender;

@end

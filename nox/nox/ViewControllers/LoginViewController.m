//
//  LoginViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "LoginViewController.h"

#import "KeychainItemWrapper.h"
#import "Profile.h"
#import "User.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)login
{
    NSString * email = [m_emailTextField text];
    NSString * password = [m_passwordTextField text];
    
    //@todo(jdiprete): send email and password to server to verify
    
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    [keychainItem setObject:password forKey:(__bridge id)kSecValueData];
    [keychainItem setObject:email forKey:(__bridge id)kSecAttrAccount];
    
    User * user = [[User alloc] init];
    //@todo(jdiprete): get user info back from server before continuing
    
    [[Profile sharedProfile] setUser:user];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - IBActions

- (IBAction)loginPressed:(id)sender
{
    [self login];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:m_passwordTextField])
    {
        [self login];
    }
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard
{
    if([m_passwordTextField isFirstResponder])
    {
        [m_passwordTextField resignFirstResponder];
    }
    else if([m_emailTextField isFirstResponder])
    {
        [m_emailTextField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

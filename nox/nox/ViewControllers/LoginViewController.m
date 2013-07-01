//
//  LoginViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "LoginViewController.h"

#import "KeychainItemWrapper.h"

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
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - IBActions

- (IBAction)loginPressed:(id)sender
{
    NSString * email = [m_emailTextField text];
    NSString * password = [m_passwordTextField text];
    
    //@todo(jdiprete): send email and password to server to verify
    
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    [keychainItem setObject:password forKey:(__bridge id)kSecValueData];
    [keychainItem setObject:email forKey:(__bridge id)kSecAttrAccount];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end

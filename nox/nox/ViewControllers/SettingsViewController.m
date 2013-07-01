//
//  SettingsViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "SettingsViewController.h"

#import "KeychainItemWrapper.h"
#import "LoginViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

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
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

#pragma mark - IBActions

- (IBAction)logoutPressed:(id)sender
{
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    [keychainItem resetKeychainItem];
    
    //@todo(jdiprete): Reset everything... 
    
    LoginViewController * loginViewController = [[LoginViewController alloc] init];
    [self.navigationController presentViewController:loginViewController animated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

@end

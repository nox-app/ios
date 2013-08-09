//
//  LoginViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "LoginViewController.h"

#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "JSONKit.h"
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

#pragma mark - Login methods

- (void)login
{
    m_email = [m_emailTextField text];
    NSString * password = [m_passwordTextField text];
    
    NSMutableDictionary * loginDictionary = [NSMutableDictionary dictionary];
    [loginDictionary setValue:m_email forKey:@"email"];
    [loginDictionary setValue:password forKey:@"password"];
    NSString * loginJSON = [loginDictionary JSONString];
    
    NSString * loginURLString = [kAPIBase stringByAppendingString:kAPILogin];
    NSURL * loginURL = [NSURL URLWithString:loginURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:loginURL];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[loginJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    m_success = NO;
    [request startAsynchronous];
}

- (void)loginWithAPIKey:(NSString *)a_apiKey
{
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    [keychainItem setObject:a_apiKey forKey:(__bridge id)kSecValueData];
    [keychainItem setObject:m_email forKey:(__bridge id)kSecAttrAccount];
    
    User * user = [[User alloc] initWithEmail:m_email];
    [[Profile sharedProfile] setUser:user];
    [[Profile sharedProfile] setApiKey:a_apiKey];
    
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (void)displayErrorMessage:(NSString *)a_error
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:a_error delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - ASIHTTPRequestDelegate Methods

- (void)request:(ASIHTTPRequest *)a_request didReceiveResponseHeaders:(NSDictionary *)a_responseHeaders
{
    int statusCode = [a_request responseStatusCode];
    NSLog(@"Login response status: %d", statusCode);
    
    if(statusCode == 200)
    {
        m_success = YES;
    }
    if(statusCode == 500)
    {
        [a_request cancel];
        [self displayErrorMessage:@"Ooops. We had a server error. Try again!"]; //@todo(jdiprete): update this message
    }
    
    m_downloadBuffer = nil;
    m_downloadBuffer = [[NSMutableData alloc] init];
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)a_data
{
    [m_downloadBuffer appendData:a_data];
}

- (void)requestFinished:(ASIHTTPRequest *)a_request
{
    JSONDecoder * decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
    
    NSDictionary * response = [decoder objectWithData:m_downloadBuffer];
    m_downloadBuffer = nil;
    NSLog(@"RESPONSE: %@", response);
    if(response)
    {
        if(m_success)
        {
            NSString * apiKey = [response objectForKey:@"api_key"];
            [self loginWithAPIKey:apiKey];
        }
        else
        {
            NSString * errorReason = [response objectForKey:@"reason"];
            [self displayErrorMessage:errorReason];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed With Error: %@", [request error]);
    [self displayErrorMessage:@"Oops. There was an error. Try again!"];
    m_downloadBuffer = nil;
}

#pragma mark - IBActions

- (IBAction)loginPressed:(id)sender
{
    [self dismissKeyboard];
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

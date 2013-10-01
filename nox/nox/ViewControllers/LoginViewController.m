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
#import "SignUpViewController.h"
#import "TextFieldCell.h"
#import "User.h"

@interface LoginViewController ()

@end

static NSString * const kTextFieldCellReuseIdentifier = @"TextFieldCellReuseIdentifier";

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
    
    [self.view setBackgroundColor:[Constants noxColor]];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [m_tableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kTextFieldCellReuseIdentifier];
    m_tableView.layer.cornerRadius = 5.0;
    m_loginPlaceholderArray = [NSArray arrayWithObjects:@"Email", @"Password", nil];
}

#pragma mark - Login methods

- (void)login
{
    [m_activityIndicator startAnimating];
    m_email = ((TextFieldCell *)[m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kLoginEmailField inSection:0]]).textField.text;
    NSString * password = ((TextFieldCell *)[m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kLoginPasswordField inSection:0]]).textField.text;
    
    NSMutableDictionary * loginDictionary = [NSMutableDictionary dictionary];
    [loginDictionary setValue:m_email forKey:@"email"];
    [loginDictionary setValue:password forKey:@"password"];
    NSString * loginJSON = [loginDictionary JSONString];
    
    NSString * loginURLString = [kNoxBase stringByAppendingString:[kAPIBase stringByAppendingString:kAPILogin]];
    NSURL * loginURL = [NSURL URLWithString:loginURLString];
    
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:loginURL];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[loginJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    m_success = NO;
    [request startAsynchronous];
}

- (void)loginWithUserDictionary:(NSDictionary *)a_dictionary apiKey:(NSString *)a_apiKey
{
    User * user = [[User alloc] initWithDictionary:a_dictionary];
    [user downloadIcon];
    [[Profile sharedProfile] setApiKey:a_apiKey];
    [[Profile sharedProfile] setUser:user];
    
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    [keychainItem setObject:a_apiKey forKey:(__bridge id)kSecValueData];
    [keychainItem setObject:m_email forKey:(__bridge id)kSecAttrAccount];
    [keychainItem setObject:[user resourceURI] forKey:(__bridge id)kSecAttrDescription];
    
    [m_activityIndicator stopAnimating];
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
    if(response)
    {
        if(m_success)
        {
            NSDictionary * userDictionary = [response objectForKey:@"user"];
            NSString * apiKey = [response objectForKey:@"api_key"];
            [self loginWithUserDictionary:userDictionary apiKey:apiKey];
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
    [m_activityIndicator stopAnimating];
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

- (IBAction)signUpPressed:(id)sender
{
    SignUpViewController * signUpViewController = [[SignUpViewController alloc] init];
    [self presentViewController:signUpViewController animated:YES completion:nil];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_loginPlaceholderArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellReuseIdentifier];
    if(cell == nil)
    {
        cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextFieldCellReuseIdentifier];
    }
    
    UIView * paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, [TextFieldCell height])];
    cell.textField.leftView = paddingView;
    cell.textField.leftViewMode = UITextFieldViewModeAlways;
    [cell.textField setDelegate:self];
    
    [cell.textField setPlaceholder:[m_loginPlaceholderArray objectAtIndex:indexPath.row]];
    
    if(indexPath.row == kLoginPasswordField)
    {
        [cell.textField setSecureTextEntry:YES];
    }
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TextFieldCell height];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    m_currentFirstResponder = textField;
}

- (void)dismissKeyboard
{
    [m_currentFirstResponder resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

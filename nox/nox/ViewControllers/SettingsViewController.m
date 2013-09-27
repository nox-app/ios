//
//  SettingsViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "SettingsViewController.h"

#import "Constants.h"
#import "KeychainItemWrapper.h"
#import "LoginViewController.h"
#import "Profile.h"
#import "Switchy.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize delegate = m_delegate;

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
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    [self addSwitches];
}

- (void)addSwitches
{
    m_publicPrivateSwitch = [[Switchy alloc] initWithFrame:CGRectMake(0, 0, 140, 34) withOnLabel:@"PUBLIC" andOfflabel:@"PRIVATE" withContainerColor1:[Constants noxColor] andContainerColor2:[Constants noxColor] withKnobColor1:[UIColor lightGrayColor] andKnobColor2:[UIColor lightGrayColor] withShine:YES];
    m_saveOriginalImagesSwitch = [[Switchy alloc] initWithFrame:CGRectMake(0, 0, 80, 34) withOnLabel:@"YES" andOfflabel:@"NO" withContainerColor1:[Constants noxColor] andContainerColor2:[Constants noxColor] withKnobColor1:[UIColor lightGrayColor] andKnobColor2:[UIColor lightGrayColor] withShine:YES];
    m_saveProcessedImagesSwitch = [[Switchy alloc] initWithFrame:CGRectMake(0, 0, 80, 34) withOnLabel:@"YES" andOfflabel:@"NO" withContainerColor1:[Constants noxColor] andContainerColor2:[Constants noxColor] withKnobColor1:[UIColor lightGrayColor] andKnobColor2:[UIColor lightGrayColor] withShine:YES];
    [self.view addSubview:m_publicPrivateSwitch];
    [m_publicPrivateSwitch setCenter:CGPointMake(245, 86)];
    [self.view addSubview:m_saveOriginalImagesSwitch];
    [m_saveOriginalImagesSwitch setCenter:CGPointMake(276, 134)];
    [self.view addSubview:m_saveProcessedImagesSwitch];
    [m_saveProcessedImagesSwitch setCenter:CGPointMake(276, 182)];
}

#pragma mark - IBActions

- (IBAction)donePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logoutPressed:(id)sender
{
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    [keychainItem resetKeychainItem];

    [[Profile sharedProfile] logout];
    
    [m_delegate logoutFromSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

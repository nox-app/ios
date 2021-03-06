//
//  CommentViewController.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CommentViewController.h"

#import "Constants.h"
#import "Event.h"
#import "Profile.h"
#import "TextPost.h"
#import "UIPlaceHolderTextView.h"
#import "User.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

- (id)initWithEvent:(Event *)a_event
{
    if(self = [super init])
    {
        m_event = a_event;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_commentTextView setPlaceholderText:@"What's going on?"];
    [m_commentTextView setPlaceholderColor:[UIColor lightGrayColor]];
    [m_commentTextView setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [m_commentTextView becomeFirstResponder];
}

- (IBAction)cancelPressed
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)postPressed
{
    NSString * text = [m_commentTextView text];
    
    TextPost * textPost = [[TextPost alloc] init];
    [textPost setBody:text];
    [textPost setTime:[NSDate date]];
    [textPost setLocation:[[Profile sharedProfile] lastLocation]];
    [textPost setUser:[[Profile sharedProfile] user]];
    [textPost setEvent:[m_event resourceURI]];
    [textPost setType:kTextType];
    
    [m_event addPost:textPost];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPostDidSucceed:) name:kAddPostDidSucceedNotification object:textPost];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPostDidFail:) name:kAddPostDidFailNotification object:textPost];
}

- (void)addPostDidSucceed:(NSNotification *)a_notification
{
    TextPost * textPost = [a_notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidSucceedNotification object:textPost];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidFailNotification object:textPost];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPostDidFail:(NSNotification *)a_notification
{
    //@todo(jdiprete): do something to tell them why it failed...
    TextPost * textPost = [a_notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidSucceedNotification object:textPost];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidFailNotification object:textPost];
}

#pragma mark - UITextView Delegate  Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([[textView text] length] - range.length + text.length > kMaxCharacterLimit)
    {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

//
//  CommentViewController.m
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CommentViewController.h"

#import "Event.h"
#import "Profile.h"
#import "TextPost.h"

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
    // Do any additional setup after loading the view from its nib.
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
}

@end

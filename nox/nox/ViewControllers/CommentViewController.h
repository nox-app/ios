//
//  CommentViewController.h
//  nox
//
//  Created by Justine DiPrete on 7/6/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface CommentViewController : UIViewController
{
    IBOutlet UITextView * m_commentTextView;
    
    Event * m_event;
}

- (id)initWithEvent:(Event *)a_event;

- (IBAction)cancelPressed;
- (IBAction)postPressed;

@end

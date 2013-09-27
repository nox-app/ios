//
//  EventViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "CommentsViewDelegate.h"
#import "EventSettingsViewControllerDelegate.h"

@class CommentTableViewDelegate;
@class Event;
@class Post;
@class UIPlaceHolderTextView;

@interface EventViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, CommentsViewDelegate, EventSettingsViewControllerDelegate>
{
    Event * m_event;
    
    Post * m_currentPost;
    IBOutlet UITableView * m_tableView;
    IBOutlet UIToolbar * m_postToolbar;
    
    IBOutlet UIActivityIndicatorView * m_activityIndicator;
    
    //Comment Elements
    IBOutlet UIView * m_commentsView;
    IBOutlet UIView * m_commentsBorderView;
    IBOutlet UITableView * m_commentsTableView;
    
    CommentTableViewDelegate * m_commentTableViewDelegate;
    IBOutlet UIPlaceHolderTextView * m_addCommentTextView;
    IBOutlet UIButton * m_postCommentButton;
    
    //Refresh Elements
    UIView * m_refreshHeaderView;
    UILabel * m_refreshLabel;
    UIActivityIndicatorView * m_refreshSpinner;
    BOOL m_isDragging;
    BOOL m_isLoading;
    
    float m_startingContentOffsetY;
    
    //Set Up Elements
    IBOutlet UIView * m_setUpView;
    IBOutlet UITextField * m_titleTextField;
    IBOutlet UITextField * m_startTimeTextField;
    IBOutlet UITextField * m_endTimeTextField;
    IBOutlet UITextField * m_locationTextField;
}


- (id)initWithEvent:(Event *)a_event;

- (IBAction)photoPressed:(id)sender;
- (IBAction)checkInPressed:(id)sender;
- (IBAction)statusUpdatePressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)closeCommentsPressed:(id)sender;
- (IBAction)postCommentPressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;

@end

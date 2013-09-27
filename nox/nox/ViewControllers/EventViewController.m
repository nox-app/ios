//
//  EventViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EventViewController.h"

#import "CameraViewController.h"
#import "CheckInViewController.h"
#import "Comment.h"
#import "CommentsView.h"
#import "CommentTableViewCell.h"
#import "CommentTableViewDelegate.h"
#import "CommentViewController.h"
#import "Constants.h"
#import "Event.h"
#import "EventDetailsTableViewCell.h"
#import "EventSettingsViewController.h"
#import "FirstCommentView.h"
#import "ImagePost.h"
#import "ImagePostTableViewCell.h"
#import "Location.h"
#import "MFSideMenu.h"
#import "PlacePost.h"
#import "PlacePostTableViewCell.h"
#import "Post.h"
#import "Profile.h"
#import "TextPost.h"
#import "TextPostTableViewCell.h"
#import "UIPlaceHolderTextView.h"
#import "User.h"
#import "Util.h"
#import "Venue.h"

@interface EventViewController ()

@end

static NSString * const kTextPostCellReuseIdentifier = @"TextPostCellReuseIdentifier";
static NSString * const kImagePostCellReuseIdentifier = @"ImagePostCellReuseIdentifier";
static NSString * const kPlacePostCellReuseIdentifier = @"PlacePostCellReuseIdentifier";
static NSString * const kEventDetailsCellReuseIdentifier = @"EventDetailsCellReuseIdentifier";

static const int kRefreshHeaderHeight = 50;
static const int kRefreshSpinnerOffset = 20;
static NSString * const kUpdatingLabel = @"Updating...";
static NSString * const kUpdatePullLabel = @"Pull to Update";
static NSString * const kUpdateReleaseLabel = @"Release to Update";

static const int kCellOffset = 10;

static const int kTextViewTag = 1;
static const int kTextBorderViewTag = 2;
static const int kFirstCommentTag = 3;
static const int kCommentsViewTag = 4;

@implementation EventViewController

#pragma mark - Initialization

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
    
    [m_tableView registerNib:[UINib nibWithNibName:@"TextPostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kTextPostCellReuseIdentifier];
    [m_tableView registerNib:[UINib nibWithNibName:@"ImagePostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kImagePostCellReuseIdentifier];
    [m_tableView registerNib:[UINib nibWithNibName:@"PlacePostTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kPlacePostCellReuseIdentifier];
    [m_tableView registerNib:[UINib nibWithNibName:@"EventDetailsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kEventDetailsCellReuseIdentifier];
    
    [self.navigationController.sideMenu setHidesRightSideMenu:NO];
    [self setupNavigationBar];
    [self setTitle:[m_event name]];
    
    //[self addSettingsView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidDownload:) name:kImagePostDidDownloadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postsDidDownload) name:kPostsDidDownloadNotification object:nil];
    
    m_commentTableViewDelegate = [[CommentTableViewDelegate alloc] initWithTableView:m_commentsTableView];
    [m_commentsTableView setDelegate:m_commentTableViewDelegate];
    [m_commentsTableView setDataSource:m_commentTableViewDelegate];
    [m_commentsView setBackgroundColor:[UIColor clearColor]];
    m_commentsBorderView.layer.cornerRadius = 5.0;
    m_commentsBorderView.layer.borderWidth = 2.0;
    m_commentsBorderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    
    [m_addCommentTextView setPlaceholderColor:[UIColor darkGrayColor]];
    [m_addCommentTextView setPlaceholderText:@"Add a comment..."];
    m_addCommentTextView.layer.cornerRadius = 5.0;
    [m_addCommentTextView setDelegate:self];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [m_commentsView addGestureRecognizer:tapGestureRecognizer];
    
    [self addPullToRefreshHeader];
}

- (void)viewDidAppear:(BOOL)animated
{
    m_startingContentOffsetY = m_tableView.contentOffset.y;
}

- (void)viewWillAppear:(BOOL)animated
{
    if([m_event postsAreDownloading])
    {
        [m_activityIndicator startAnimating];
    }
    [m_tableView reloadData];
}

- (void)setupNavigationBar
{
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[Constants noxColor]];
    UIBarButtonItem * homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"53-house.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(homePressed)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    UIBarButtonItem * friendsMenuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered target:self.navigationController.sideMenu action:@selector(toggleRightSideMenu)];
    [self.navigationItem setRightBarButtonItem:friendsMenuButton];
}

- (void)viewDidTap:(UIGestureRecognizer *)a_gestureRecognizer
{
    [m_addCommentTextView resignFirstResponder];
}

- (void)commentShouldUpdate:(NSNotification *)a_notification
{
    Comment * comment = [a_notification object];
    
    NSUInteger index = [[m_currentPost comments] indexOfObject:comment];
    if(index != NSNotFound)
    {
        [m_commentsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)postCommentPressed:(id)sender
{
    NSString * commentBody = [m_addCommentTextView text];
    if([commentBody length] > 0)
    {
        Comment * comment = [[Comment alloc] init];
        [comment setBody:commentBody];
        [comment setUser:[[Profile sharedProfile] user]];
        [comment setLocation:[[Profile sharedProfile] lastLocation]];
        [comment setTime:[NSDate date]];
        [m_currentPost addComment:comment];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postCommentDidSucceed) name:kCommentAddDidSucceedNotification object:m_currentPost];
}

- (void)postCommentDidSucceed
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCommentAddDidSucceedNotification object:m_currentPost];
    [m_commentsTableView reloadData];
    [m_addCommentTextView resignFirstResponder];
    [m_addCommentTextView setText:@""];
    
    [self reloadRowForPost:m_currentPost];

}

- (void)reloadRowForPost:(Post *)a_post
{
    NSUInteger index = [[m_event posts] indexOfObject:a_post];
    if(index != NSNotFound)
    {
        [m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)updatePost:(NSNotification *)a_notification
{
    Post * post = [a_notification object];
    [self reloadRowForPost:post];
}

#pragma mark - CommentsView Delegate Methods

- (void)expandCommentsPressedForPost:(Post *)a_post
{
    m_currentPost = a_post;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsDidDownload:) name:kCommentsDidDownloadNotification object:a_post];
    [a_post downloadComments];
    [m_commentTableViewDelegate setPost:a_post];
    [m_commentsView setFrame:CGRectMake(0, self.view.frame.size.height, m_commentsView.frame.size.width, m_commentsView.frame.size.height)];
    [self.view addSubview:m_commentsView];
    [UIView animateWithDuration:0.3 animations:^(void)
     {
          [m_commentsView setCenter:self.view.center];
     }];
}

- (void)likePressedForPost:(Post *)a_post
{
    [a_post addLike];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePost:) name:kLikeAddDidSucceedNotification object:nil];
}
- (void)dislikePressedForPost:(Post *)a_post
{
    [a_post addDislike];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePost:) name:kDislikeAddDidSucceedNotification object:nil];
}


#pragma mark - UITextView methods

- (void)keyboardWillShow:(NSNotification *)a_notification
{
    if([m_addCommentTextView isFirstResponder])
    {
        NSDictionary * keyboardInfo = [a_notification userInfo];
        NSValue * keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        [UIView animateWithDuration:0.26f animations:^ {
            [m_commentsTableView setFrame:CGRectMake(m_commentsTableView.frame.origin.x, m_commentsTableView.frame.origin.y, m_commentsTableView.frame.size.width, m_commentsTableView.frame.size.height - keyboardFrameBeginRect.size.height)];
            [m_addCommentTextView setFrame:CGRectMake(m_addCommentTextView.frame.origin.x, m_addCommentTextView.frame.origin.y - keyboardFrameBeginRect.size.height, m_addCommentTextView.frame.size.width, m_addCommentTextView.frame.size.height)];
            [m_postCommentButton setFrame:CGRectMake(m_postCommentButton.frame.origin.x, m_postCommentButton.frame.origin.y - keyboardFrameBeginRect.size.height, m_postCommentButton.frame.size.width, m_postCommentButton.frame.size.height)];
            CGPoint offset = CGPointMake(0, m_commentsTableView.contentSize.height - m_commentsTableView.frame.size.height);
            if(offset.y > 0)
            {
                [m_commentsTableView setContentOffset:offset animated:YES];
            }
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)a_notification
{
    if([m_addCommentTextView isFirstResponder])
    {
        NSDictionary * keyboardInfo = [a_notification userInfo];
        NSValue * keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        [UIView animateWithDuration:0.22f animations:^ {
            [m_commentsTableView setFrame:CGRectMake(m_commentsTableView.frame.origin.x, m_commentsTableView.frame.origin.y, m_commentsTableView.frame.size.width, m_commentsTableView.frame.size.height + keyboardFrameBeginRect.size.height)];
            [m_addCommentTextView setFrame:CGRectMake(m_addCommentTextView.frame.origin.x, m_addCommentTextView.frame.origin.y + keyboardFrameBeginRect.size.height, m_addCommentTextView.frame.size.width, m_addCommentTextView.frame.size.height)];
            [m_postCommentButton setFrame:CGRectMake(m_postCommentButton.frame.origin.x, m_postCommentButton.frame.origin.y + keyboardFrameBeginRect.size.height, m_postCommentButton.frame.size.width, m_postCommentButton.frame.size.height)];
            //self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    float heightDifference = textView.contentSize.height - textView.frame.size.height;
    [m_commentsTableView setFrame:CGRectMake(m_commentsTableView.frame.origin.x, m_commentsTableView.frame.origin.y, m_commentsTableView.frame.size.width, m_commentsTableView.frame.size.height - heightDifference)];
    CGPoint offset = CGPointMake(0, m_commentsTableView.contentSize.height - m_commentsTableView.frame.size.height);
    if(offset.y > 0)
    {
        [m_commentsTableView setContentOffset:offset animated:NO];
    }
    [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y - heightDifference, textView.frame.size.width, textView.contentSize.height)];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"Text View Ended!");
}

#pragma mark - Download methods

- (void)commentsDidDownload:(NSNotification *)a_notification
{
    [m_commentsTableView reloadData];
}

- (void)postsDidDownload
{
    [m_activityIndicator stopAnimating];
    [m_tableView reloadData];
}

- (void)imageDidDownload:(NSNotification *)a_notification
{
    ImagePost * imagePost = [a_notification object];
    
    //todo(jdiprete): Is this better than just reloading every time?
    NSUInteger index = [[m_event posts] indexOfObject:imagePost];
    if(index != NSNotFound)
    {
        [m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Settings Methods

- (void)presentSettingsViewController
{
    EventSettingsViewController * eventSettingsViewController = [[EventSettingsViewController alloc] initWithEvent:m_event];
    [eventSettingsViewController setDelegate:self];
    [self presentViewController:eventSettingsViewController animated:YES completion:nil];
}

- (void)editEventDetailsPressed
{
    [self presentSettingsViewController];
}

- (IBAction)settingsPressed:(id)sender
{
    [self presentSettingsViewController];
}

#pragma mark - EventSettingsViewController Delegate Methods

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:NO completion:^(void)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (void)updateEvent
{
    [self setTitle:[m_event name]];
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isEqual:m_startTimeTextField] || [textField isEqual:m_endTimeTextField])
    {
        [self addDateActionSheet];
        return NO;
    }
    return YES;
}

- (void)addDateActionSheet
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Date" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select", nil];
    [actionSheet showInView:self.view];
    [actionSheet setFrame:CGRectMake(0, 200, self.view.frame.size.width, 383)];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    UIDatePicker * datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 50, 100, 116)];
    [actionSheet addSubview:datePicker];
    
    //Gets an array af all of the subviews of our actionSheet
    NSArray * subviews = [actionSheet subviews];
    for(UIView * view in subviews)
    {
        NSLog(@"VIEW: %@", view);
    }
    
    [[subviews objectAtIndex:2] setFrame:CGRectMake(20, 266, 280, 46)];
    [[subviews objectAtIndex:3] setFrame:CGRectMake(20, 317, 280, 46)];
}

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

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 1)
    {
        return 1;
    }
    else
    {
        return [[m_event posts] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        EventDetailsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kEventDetailsCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[EventDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventDetailsCellReuseIdentifier];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.borderView.layer.cornerRadius = 5.0;
        cell.borderView.layer.borderWidth = 2.0;
        cell.borderView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        cell.locationLabel.layer.cornerRadius = 5.0;
        cell.locationLabel.layer.borderWidth = 2.0;
        cell.locationLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        [cell.titleLabel setText:[m_event name]];
        [cell.startLabel setText:[Util stringFromDate:[m_event startedAt]]];
        
        //@todo(jdiprete): This should be set as the event's location
        [cell.locationLabel setText:[[Profile sharedProfile] currentCity]];
        
        if([m_event endedAt] == nil)
        {
            [cell.endLabel setText:@"Ongoing"];
        }
        else
        {
            [cell.endLabel setText:[Util stringFromDate:[m_event endedAt]]];
        }
        
        [cell.editButton addTarget:self action:@selector(editEventDetailsPressed) forControlEvents:UIControlEventTouchUpInside];
        
        
        return cell;
    }
    else
    {
        Post * post = [[m_event posts] objectAtIndex:indexPath.row];
        PostType type = [post type];
        
        if(type == kImageType)
        {
            ImagePost * post = [[m_event posts] objectAtIndex:indexPath.row];
            
            ImagePostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kImagePostCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[ImagePostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kImagePostCellReuseIdentifier];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            [cell.userName setText:[NSString stringWithFormat:@"%@ %@", [[post user] firstName], [[post user] lastName]]];
            [cell.postImageView setImage:[post image]];
            [[cell timeLabel] setText:[Util stringFromDate:[post time]]];
            
            if([post imageIsDownloading])
            {
                [cell.activityIndicator startAnimating];
            }
            else
            {
                [cell.activityIndicator stopAnimating];
            }
            
            [[cell viewWithTag:kCommentsViewTag] removeFromSuperview];
            [[cell viewWithTag:kFirstCommentTag] removeFromSuperview];
            CommentsView * commentsView = [[CommentsView alloc] init];
            [commentsView setFrame:CGRectMake(0, [ImagePostTableViewCell height], 320, kCommentViewHeight)];
            [cell.contentView addSubview:commentsView];
            
            [commentsView setTag:kCommentsViewTag];
            
            [commentsView setDelegate:self];
            [commentsView setPost:post];
            [[commentsView likeNumberLabel] setText:[NSString stringWithFormat:@"%d", [post likeCount]]];
            [[commentsView dislikeNumberLabel] setText:[NSString stringWithFormat:@"%d", [post dislikeCount]]];
            
            if([post opinion] == kLiked)
            {
                [[commentsView likeButton] setHighlighted:YES];
            }
            else if([post opinion] == kDisliked)
            {
                [[commentsView dislikeButton] setHighlighted:YES];
            }
            
            if([post commentCount] == 1)
            {
                [[commentsView commentsButton] setTitle:@"1 Comment" forState:UIControlStateNormal];
            }
            else
            {
                [[commentsView commentsButton] setTitle:[NSString stringWithFormat:@"%d Comments", [post commentCount]] forState:UIControlStateNormal];
            }
            
            if([post commentCount] > 0)
            {
                FirstCommentView * firstCommentView = [self firstCommentViewForPost:post atPosition:CGPointMake(0, [ImagePostTableViewCell height] + kCommentViewHeight)];
                [cell.contentView addSubview:firstCommentView];
            }
            return cell;
            
        }
        else if(type == kTextType)
        {
            TextPost * post = [[m_event posts] objectAtIndex:indexPath.row];
            
            TextPostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kTextPostCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[TextPostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextPostCellReuseIdentifier];
            }
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            [[cell viewWithTag:kTextViewTag] removeFromSuperview];
            [[cell viewWithTag:kTextBorderViewTag] removeFromSuperview];
            
            UIView * borderView = [[UIView alloc] initWithFrame:CGRectMake(5, 62, 310, 50)];
            [borderView setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]];
            borderView.layer.cornerRadius = 5.0;
            borderView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            borderView.layer.borderWidth = 1.0;
            [borderView setTag:kTextBorderViewTag];
            [cell.contentView addSubview:borderView];
            
            UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(13, 70, 285, 32)];
            [textView setBackgroundColor:[UIColor clearColor]];
            [textView setScrollEnabled:NO];
            [textView setEditable:NO];
            [textView setFont:[UIFont systemFontOfSize:14]];
            [cell.contentView addSubview:textView];
            [textView setTag:kTextViewTag];
            
            [textView setText:[post body]];
            
            CGSize commentSize = [[post body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(285, 999)];
            int heightDifference = 0;
            if(commentSize.height > 32)
            {
                heightDifference = commentSize.height - 32 + 20;
            }
            NSLog(@"HEIGHT DIFFERENCE: %d", heightDifference);
            
            CGRect textViewFrame = textView.frame;
            textViewFrame.size.height += heightDifference;
            [textView setFrame:textViewFrame];
            
            CGRect borderFrame = borderView.frame;
            borderFrame.size.height += heightDifference;
            [borderView setFrame:borderFrame];
            
            [cell.userName setText:[NSString stringWithFormat:@"%@ %@", [[post user] firstName], [[post user] lastName]]];
            [[cell timeLabel] setText:[Util stringFromDate:[post time]]];
            
            [[cell viewWithTag:kCommentsViewTag] removeFromSuperview];
            [[cell viewWithTag:kFirstCommentTag] removeFromSuperview];
            CommentsView * commentsView = [[CommentsView alloc] init];
            [commentsView setTag:kCommentsViewTag];
            
            CGRect commentsViewFrame = CGRectMake(0, 120 + heightDifference, 320, 40);
            [commentsView setFrame:commentsViewFrame];
            [cell.contentView addSubview:commentsView];
            
            [commentsView setDelegate:self];
            [commentsView setPost:post];
            [commentsView setBackgroundColor:[UIColor greenColor]];
            [[commentsView likeNumberLabel] setText:[NSString stringWithFormat:@"%d", [post likeCount]]];
            [[commentsView dislikeNumberLabel] setText:[NSString stringWithFormat:@"%d", [post dislikeCount]]];
            
            if([post opinion] == kLiked)
            {
                [[commentsView likeButton] setHighlighted:YES];
            }
            else if([post opinion] == kDisliked)
            {
                [[commentsView dislikeButton] setHighlighted:YES];
            }
            
            if([post commentCount] == 1)
            {
                [[commentsView commentsButton] setTitle:@"1 Comment" forState:UIControlStateNormal];
            }
            else
            {
                [[commentsView commentsButton] setTitle:[NSString stringWithFormat:@"%d Comments", [post commentCount]] forState:UIControlStateNormal];
            }
            
            if([post commentCount] > 0)
            {
                FirstCommentView * firstCommentView = [self firstCommentViewForPost:post atPosition:CGPointMake(0, [TextPostTableViewCell height] + heightDifference + kCommentViewHeight)];
                [cell.contentView addSubview:firstCommentView];
            }
            
            return cell;
        }
        else //type is place
        {
            PlacePost * post = [[m_event posts] objectAtIndex:indexPath.row];
            
            PlacePostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kPlacePostCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[PlacePostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPlacePostCellReuseIdentifier];
            }
            [cell setSelectionStyle:UITableViewCellEditingStyleNone];
            
            [[cell placeNameLabel] setText:[[post venue] name]];
            [[cell cityStateLabel] setText:[NSString stringWithFormat:@"%@, %@", [[[post venue] location] city], [[[post venue] location] state]]];
            
            [[cell timeLabel] setText:[Util stringFromDate:[post time]]];
            
            [[cell iconImageView] setImage:[[post venue] iconImage]];
            
            [[cell backgroundBorderView].layer setBorderColor:[UIColor darkGrayColor].CGColor];
            [[cell backgroundBorderView].layer setBorderWidth:2.0];
            [[cell backgroundBorderView].layer setCornerRadius:5.0];
            
            [cell.commentsView setDelegate:self];
            [cell.commentsView setPost:post];
            [[cell.commentsView likeNumberLabel] setText:[NSString stringWithFormat:@"%d", [post likeCount]]];
            [[cell.commentsView dislikeNumberLabel] setText:[NSString stringWithFormat:@"%d", [post dislikeCount]]];
            if([post commentCount] == 1)
            {
                [[cell.commentsView commentsButton] setTitle:@"1 Comment" forState:UIControlStateNormal];
            }
            else
            {
                [[cell.commentsView commentsButton] setTitle:[NSString stringWithFormat:@"%d Comments", [post commentCount]] forState:UIControlStateNormal];
            }
            
            if([post commentCount] > 0)
            {
                [cell.firstCommentView.timeLabel setText:[Util stringFromDate:[post firstComment].time]];
            }
            else
            {
                [cell setShowsFirstComment:NO];
            }
            return cell;
        }
    }
}

- (FirstCommentView *)firstCommentViewForPost:(Post *)a_post atPosition:(CGPoint)a_position
{
    CGSize firstCommentSize = [[[a_post firstComment] body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake([FirstCommentView textViewBaseFrame].size.width, 999)];
    int heightDifference = 0;
    if(firstCommentSize.height > 30)
    {
        heightDifference = firstCommentSize.height - 30 + kFirstCommentTextViewOffset;
    }
    
    FirstCommentView * firstCommentView = [[FirstCommentView alloc] init];
    [firstCommentView setTag:kFirstCommentTag];
    
    CGRect firstCommentViewFrame = CGRectMake(a_position.x, a_position.y, 320, kFirstCommentHeight);
    firstCommentViewFrame.size.height += heightDifference;
    [firstCommentView setFrame:firstCommentViewFrame];
    
    CGRect firstCommentTextViewFrame = [FirstCommentView textViewBaseFrame];
    firstCommentTextViewFrame.size.height += heightDifference;
    
    UITextView * textView = [[UITextView alloc] initWithFrame:firstCommentTextViewFrame];
    [textView setFont:[UIFont systemFontOfSize:14]];
    [textView setText:[a_post firstComment].body];
    [textView setScrollEnabled:NO];
    [textView setEditable:NO];
    [firstCommentView addSubview:textView];
    
    [firstCommentView.timeLabel setText:[Util stringFromDate:[a_post firstComment].time]];
    [firstCommentView.userName setText:[NSString stringWithFormat:@"%@ %@", [[a_post firstComment] user].firstName, [[a_post firstComment] user].lastName]];
    
    return firstCommentView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsDisplay];
    //[m_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 1)
    {
        return [EventDetailsTableViewCell height];
    }
    else
    {
        Post * post = [[m_event posts] objectAtIndex:indexPath.row];
        PostType type = [post type];
        float commentViewHeight = kCommentViewHeight;
        if([post commentCount] > 0)
        {
            CGSize firstCommentSize = [[[post firstComment] body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake([FirstCommentView textViewBaseFrame].size.width, 999)];
            int heightDifference = 0;
            if(firstCommentSize.height > 30)
            {
                heightDifference = firstCommentSize.height - 30 + kFirstCommentTextViewOffset;
            }
            commentViewHeight += kFirstCommentHeight + heightDifference;
        }
        if(type == kTextType)
        {
            CGSize postSize = [[(TextPost *)post body] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(285, 999)];
            int heightDifference = 0;
            if(postSize.height > 32)
            {
                heightDifference = postSize.height - 32 + 20;
            }
            return [TextPostTableViewCell height] + commentViewHeight + kCellOffset + heightDifference;
        }
        else if(type == kImageType)
        {
            return [ImagePostTableViewCell height] + commentViewHeight + kCellOffset;
        }
        else
        {
            return [PlacePostTableViewCell height] + commentViewHeight + kCellOffset;
        }
    }
}

#pragma mark - IBActions

- (IBAction)closeCommentsPressed:(id)sender
{
    [m_addCommentTextView resignFirstResponder];
    [m_addCommentTextView setText:@""];
    m_currentPost = nil;
    [m_commentTableViewDelegate setPost:nil];
    [m_commentsTableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCommentsDidDownloadNotification object:nil];

    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [m_commentsView setFrame:CGRectMake(0, self.view.frame.size.height, m_commentsView.frame.size.width, m_commentsView.frame.size.height)];
     } completion:^(BOOL a_bool)
     {
         [m_commentsView removeFromSuperview];
     }];
}

- (IBAction)photoPressed:(id)sender
{
    CameraViewController * cameraViewController = [[CameraViewController alloc] initWithEvent:m_event];
    [self presentViewController:cameraViewController animated:YES completion:nil];
}

- (IBAction)checkInPressed:(id)sender
{
    CheckInViewController * checkInViewController = [[CheckInViewController alloc] initWithEvent:m_event];
    [self presentViewController:checkInViewController animated:YES completion:nil];
}

- (IBAction)statusUpdatePressed:(id)sender
{
    CommentViewController * commentViewController = [[CommentViewController alloc] initWithEvent:m_event];
    [self presentViewController:commentViewController animated:YES completion:nil];
}

- (IBAction)deletePressed:(id)sender
{
    [[Profile sharedProfile] deleteEvent:m_event];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)homePressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Refresh Methods

- (void)addPullToRefreshHeader
{
    m_refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - kRefreshHeaderHeight, 320, kRefreshHeaderHeight)];
    m_refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, kRefreshHeaderHeight)];
    [m_refreshLabel setTextAlignment:NSTextAlignmentCenter];
    [m_refreshLabel setFont:[UIFont systemFontOfSize:10]];
    m_refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [m_refreshSpinner setFrame:CGRectMake(floorf((kRefreshHeaderHeight - kRefreshSpinnerOffset)/2), floorf((kRefreshHeaderHeight - kRefreshSpinnerOffset) /2), kRefreshSpinnerOffset, kRefreshSpinnerOffset)];
    [m_refreshSpinner setHidesWhenStopped:YES];
    [m_refreshHeaderView addSubview:m_refreshLabel];
    [m_refreshHeaderView addSubview:m_refreshSpinner];
    [m_tableView addSubview:m_refreshHeaderView];
}

- (void)startLoading
{
    m_isLoading = YES;
    m_tableView.contentInset = UIEdgeInsetsMake(kRefreshHeaderHeight - m_startingContentOffsetY, 0, 0, 0);
    m_refreshLabel.text = kUpdatingLabel;
    [m_refreshSpinner startAnimating];
    
    //Update!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDidSucceed) name:kPostsDidDownloadNotification object:m_event];
    [m_event downloadPosts];
}

- (void)stopLoading
{
    m_isLoading = NO;
    [m_refreshSpinner stopAnimating];
    m_tableView.contentInset = UIEdgeInsetsMake(-m_startingContentOffsetY, 0, 0, 0);
}

- (void)updateDidSucceed
{
    NSLog(@"Update Succeeded");
    [m_activityIndicator stopAnimating];
    if(m_isLoading)
    {
        [self stopLoading];
    }
    [m_tableView reloadData];
}

- (void)updateDidFail
{
    [m_activityIndicator stopAnimating];
    if(m_isLoading)
    {
        [self stopLoading];
    }
    [m_tableView reloadData];
}

#pragma mark - UIScrollView methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(!m_isLoading)
    {
        m_isDragging = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(m_isLoading)
    {
//        //todo(jdiprete): I think these numbers are off
//        if(scrollView.contentOffset.y > m_startingContentOffsetY)
//        {
//            NSLog(@"Content Offset: %f, Starting Offset: %f", scrollView.contentOffset.y, m_startingContentOffsetY);
//            m_tableView.contentInset = UIEdgeInsetsMake(-m_startingContentOffsetY, 0, 0, 0);
//        }
//        else if(scrollView.contentOffset.y - m_startingContentOffsetY >= -kRefreshHeaderHeight)
//        {
//            NSLog(@"Content Offset: %f, Starting Offset: %f, Refresh Header: %d", scrollView.contentOffset.y, m_startingContentOffsetY, kRefreshHeaderHeight);
//            m_tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y - m_startingContentOffsetY, 0, 0, 0);
//            NSLog(@"Setting Y to: %f", -scrollView.contentOffset.y - m_startingContentOffsetY);
//        }
    }
    else if(m_isDragging && scrollView.contentOffset.y < 0)
    {
        if(scrollView.contentOffset.y - m_startingContentOffsetY < -kRefreshHeaderHeight)
        {
            m_refreshLabel.text = kUpdateReleaseLabel;
        }
        else
        {
            m_refreshLabel.text = kUpdatePullLabel;
        }
    }
}

/**
 * If the table view has been scrolled down far enough, this calls
 * startLoading to update the news feed.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    m_isDragging = NO;
    if(scrollView.contentOffset.y - m_startingContentOffsetY <= -kRefreshHeaderHeight)
    {
        [self startLoading];
    }
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

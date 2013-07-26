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
#import "CommentsView.h"
#import "CommentViewController.h"
#import "Event.h"
#import "ImagePost.h"
#import "ImagePostTableViewCell.h"
#import "Location.h"
#import "MFSideMenu.h"
#import "PlacePost.h"
#import "PlacePostTableViewCell.h"
#import "Post.h"
#import "TextPost.h"
#import "TextPostTableViewCell.h"
#import "Venue.h"

@interface EventViewController ()

@end

static NSString * const kTextPostCellReuseIdentifier = @"TextPostCellReuseIdentifier";
static NSString * const kImagePostCellReuseIdentifier = @"ImagePostCellReuseIdentifier";
static NSString * const kPlacePostCellReuseIdentifier = @"PlacePostCellReuseIdentifier";

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
    
    [self.navigationController.sideMenu setHidesRightSideMenu:NO];
    [self setupNavigationBar];
    [self setTitle:[m_event name]];
    
    [self addSettingsView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [m_tableView reloadData];
    
    if([[m_event posts] count] == 0)
    {
        [self bounceSettingsView];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    //The date picker is slow as fuck. Create it here, so it doesn't slow down the VC presentation...
    m_endDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 120, m_endDatePicker.frame.size.width, m_endDatePicker.frame.size.height)];
    [m_settingsView addSubview:m_endDatePicker];
    [m_endDatePicker setDate:[m_event endedAt]];
}

- (void)setupNavigationBar
{
    [self.navigationItem setHidesBackButton:YES];
    UIBarButtonItem * homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"53-house.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(homePressed)];
    [self.navigationItem setLeftBarButtonItem:homeButton];
    
    UIBarButtonItem * friendsMenuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStyleBordered target:self.navigationController.sideMenu action:@selector(toggleRightSideMenu)];
    [self.navigationItem setRightBarButtonItem:friendsMenuButton];
}

#pragma mark - Settings View Methods

- (void)addSettingsView
{
    m_settingsMaximumY = self.view.frame.size.height - m_postToolbar.frame.size.height - m_settingsTabView.frame.size.height;
    m_settingsMinimumY = self.view.frame.size.height - m_postToolbar.frame.size.height - m_settingsView.frame.size.height;
    [m_settingsView setFrame:CGRectMake(0, m_settingsMaximumY, m_settingsView.frame.size.width, m_settingsView.frame.size.height)];
    [self.view addSubview:m_settingsView];
    [self.view bringSubviewToFront:m_postToolbar];
    
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragSettingsView:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [panGestureRecognizer setDelegate:self];
    [m_settingsView addGestureRecognizer:panGestureRecognizer];
    
    [m_eventNameTextField setText:[m_event name]];
}

- (void)dragSettingsView:(UIGestureRecognizer *)a_gestureRecognizer
{
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)a_gestureRecognizer translationInView:self.view];
    
    if([(UIPanGestureRecognizer *)a_gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        m_settingsStartY = m_settingsView.frame.origin.y;
	}
	
	translatedPoint = CGPointMake(m_settingsView.frame.origin.x, m_settingsStartY + translatedPoint.y);
	
    if(translatedPoint.y > m_settingsMaximumY)
    {
        [m_settingsView setFrame:CGRectMake(translatedPoint.x, m_settingsMaximumY, m_settingsView.frame.size.width, m_settingsView.frame.size.height)];
    }
    else if(translatedPoint.y < m_settingsMinimumY)
    {
        [m_settingsView setFrame:CGRectMake(translatedPoint.x, m_settingsMinimumY, m_settingsView.frame.size.width, m_settingsView.frame.size.height)];
    }
    else
    {
        [m_settingsView setFrame:CGRectMake(translatedPoint.x, translatedPoint.y, m_settingsView.frame.size.width, m_settingsView.frame.size.height)];
    }
	
	if([(UIPanGestureRecognizer*)a_gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        float velocity = [(UIPanGestureRecognizer*)a_gestureRecognizer velocityInView:self.view].y;
        
        float finalY = translatedPoint.y;
        
        if(velocity < 0) //moving up
        {
            if(translatedPoint.y < m_settingsMaximumY - ((m_settingsMaximumY - m_settingsMinimumY)*.2))
            {
                finalY = m_settingsMinimumY;
            }
            else
            {
                finalY = m_settingsMaximumY;
            }
        }
        else // moving down
        {
            if(translatedPoint.y > m_settingsMinimumY + ((m_settingsMaximumY - m_settingsMinimumY)*.2))
            {
                finalY = m_settingsMaximumY;
            }
            else
            {
                finalY = m_settingsMinimumY;
            }
		}
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [m_settingsView setFrame:CGRectMake(translatedPoint.x, finalY, m_settingsView.frame.size.width, m_settingsView.frame.size.height)];
		[UIView commitAnimations];
    }

}


//@todo(jdiprete): bounce better
- (void)bounceSettingsView
{
    [UIView animateWithDuration:0.3 animations:^
     {
         [m_settingsView setCenter:CGPointMake(m_settingsView.center.x, m_settingsView.center.y - 40)];
     }completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.2 animations:^
          {
              [m_settingsView setCenter:CGPointMake(m_settingsView.center.x, m_settingsView.center.y + 40)];
          }completion:^(BOOL finished)
          {
              [UIView animateWithDuration:0.2 animations:^
               {
                   [m_settingsView setCenter:CGPointMake(m_settingsView.center.x, m_settingsView.center.y - 20)];
               }completion:^(BOOL finished)
               {
                   [UIView animateWithDuration:0.1 animations:^
                    {
                        [m_settingsView setCenter:CGPointMake(m_settingsView.center.x, m_settingsView.center.y + 20)];
                    }completion:^(BOOL finished)
                    {
                        
                    }];
               }];
          }];
     }];
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

- (void)dismissKeyboard
{
    [m_eventNameTextField resignFirstResponder];
}

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[m_event posts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostType type = [(Post *)[[m_event posts] objectAtIndex:indexPath.row] type];
    
    if(type == kImageType)
    {
        ImagePost * post = [[m_event posts] objectAtIndex:indexPath.row];
        
        ImagePostTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kImagePostCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[ImagePostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kImagePostCellReuseIdentifier];
        }
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        
        [cell.postImageView setImage:[post image]];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mma"];
        [[cell timeLabel] setText:[[formatter stringFromDate:[post time]] lowercaseString]];
        
        CommentsView * commentsView = [[CommentsView alloc] init];
        [[commentsView likeNumberLabel] setText:@"0"];
        [[commentsView dislikeNumberLabel] setText:@"0"];
        [[commentsView commentNumberLabel] setText:@"0 Comments"];
        [[cell commentsView] addSubview:commentsView];
        
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
        
        [cell.textView setText:[post body]];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mma"];
        [[cell timeLabel] setText:[[formatter stringFromDate:[post time]] lowercaseString]];
        
        CommentsView * commentsView = [[CommentsView alloc] init];
        [[commentsView likeNumberLabel] setText:@"0"];
        [[commentsView dislikeNumberLabel] setText:@"0"];
        [[commentsView commentNumberLabel] setText:@"0 Comments"];
        [[cell commentsView] addSubview:commentsView];
        
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
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mma"];
        [[cell timeLabel] setText:[[formatter stringFromDate:[post time]] lowercaseString]];
        
        [[cell iconImageView] setImage:[[post venue] iconImage]];
        
        [[cell backgroundBorderView].layer setBorderColor:[UIColor blackColor].CGColor];
        [[cell backgroundBorderView].layer setBorderWidth:3.0];
        
        CommentsView * commentsView = [[CommentsView alloc] init];
        [[commentsView likeNumberLabel] setText:@"0"];
        [[commentsView dislikeNumberLabel] setText:@"0"];
        [[commentsView commentNumberLabel] setText:@"0 Comments"];
        [[cell commentsView] addSubview:commentsView];
        
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostType type = [(Post *)[[m_event posts] objectAtIndex:indexPath.row] type];
    switch(type)
    {
        case kTextType:
            return [TextPostTableViewCell height];
            break;
        case kImageType:
            return [ImagePostTableViewCell height];
            break;
        case kPlaceType:
            return [PlacePostTableViewCell height];
            break;
        default:
            break;
    }
}

#pragma mark - IBActions

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

- (IBAction)saveSettingsPressed:(id)sender
{
    //@todo(jdiprete):send this info to the server to update
    [m_event setName:[m_eventNameTextField text]];
    [self setTitle:[m_event name]];
    [m_event setEndedAt:[m_endDatePicker date]];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.35];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [m_settingsView setFrame:CGRectMake(m_settingsView.frame.origin.x, m_settingsMaximumY, m_settingsView.frame.size.width, m_settingsView.frame.size.height)];
    [UIView commitAnimations];
}

- (void)homePressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

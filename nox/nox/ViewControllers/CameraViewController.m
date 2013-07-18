//
//  CameraViewController.m
//  nox
//
//  Created by Justine DiPrete on 7/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "CameraViewController.h"

#import "Constants.h"
#import "Event.h"
#import "ImagePost.h"
#import "PictureEditView.h"
#import "Profile.h"
#import "UIPlaceHolderTextView.h"

@interface CameraViewController ()

@end

static const float kPictureYOffset = 20.0;
static const float kPictureXOffset = 20.0;

static const float kKeyboardOffset = 120.0;

@implementation CameraViewController

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
    
    m_photoArray = [[NSMutableArray alloc] init];
    m_imagePostArray = [[NSMutableArray alloc] init];
    
    m_pictureEditView = [[[NSBundle mainBundle] loadNibNamed:@"PictureEditView" owner:self options:nil] objectAtIndex:0];
    m_editCaptionTextView.layer.borderWidth = 3.0;
    m_editCaptionTextView.layer.borderColor = [UIColor blackColor].CGColor;
    m_editCaptionTextView.layer.cornerRadius = 5.0;
    [m_editCaptionTextView setPlaceholderText:@"Enter your caption"];
    [m_editCaptionTextView setPlaceholderColor:[UIColor lightGrayColor]];
    [m_editCaptionTextView setDelegate:self];
    
    [self setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    [self setShowsCameraControls:NO];
    [self setNavigationBarHidden:YES];
    [self setToolbarHidden:YES];
    [self setWantsFullScreenLayout:YES];
    
    UIView * cameraOverlay = [[[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil] objectAtIndex:0];
    
    [self setCameraOverlayView:cameraOverlay];
    [self setDelegate:self];
}

#pragma mark - Photo Edit Methods

- (void)pictureDidTap:(UIGestureRecognizer *)a_gestureRecognizer
{
    for(int i = 0; i < [m_photoArray count]; i++)
    {
        if([a_gestureRecognizer.view isEqual:[m_photoArray objectAtIndex:i]])
        {
            [self openPictureEditViewForImageAtIndex:i];
            break;
        }
    }
}

- (void)openPictureEditViewForImageAtIndex:(NSInteger)a_index
{
    m_currentImagePost = [m_imagePostArray objectAtIndex:a_index];
    [m_pictureEditView setImage:[m_currentImagePost image]];
    [m_pictureEditView setFrame:CGRectMake(0, 25, m_pictureEditView.frame.size.width, m_pictureEditView.frame.size.height)];
    [m_editCaptionTextView setText:[m_currentImagePost caption]];
    [self.view addSubview:m_pictureEditView];
}

- (IBAction)cancelPictureEditPressed:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [m_pictureEditView setFrame:CGRectMake(m_pictureEditView.frame.origin.x, [UIScreen mainScreen].bounds.size.height, m_pictureEditView.frame.size.width, m_pictureEditView.frame.size.height)];
     }completion:^(BOOL finished)
     {
         [m_pictureEditView removeFromSuperview];
     }];
    [m_editCaptionTextView setText:@""];
}

- (IBAction)savePictureEditPressed:(id)sender
{
    [m_currentImagePost setCaption:[m_editCaptionTextView text]];
    
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [m_pictureEditView setFrame:CGRectMake(m_pictureEditView.frame.origin.x, [UIScreen mainScreen].bounds.size.height, m_pictureEditView.frame.size.width, m_pictureEditView.frame.size.height)];
     }completion:^(BOOL finished)
     {
         [m_pictureEditView removeFromSuperview];
         [m_editCaptionTextView setText:@""];
     }];
}

#pragma mark - UITextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [m_pictureEditView setFrame:CGRectMake(m_pictureEditView.frame.origin.x, m_pictureEditView.frame.origin.y - kKeyboardOffset, m_pictureEditView.frame.size.width, m_pictureEditView.frame.size.height)];
     }completion:nil];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [m_pictureEditView setFrame:CGRectMake(m_pictureEditView.frame.origin.x, m_pictureEditView.frame.origin.y + kKeyboardOffset, m_pictureEditView.frame.size.width, m_pictureEditView.frame.size.height)];
     }completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    else if([[textView text] length] - range.length + text.length > kMaxCharacterLimit)
    {
        return NO;
    }
    return YES;
}

#pragma mark - Photo View Methods

- (void)addPhotoToView:(UIImage *)a_picture
{
    //Create the image post
    ImagePost * imagePost = [[ImagePost alloc] init];
    [imagePost setTime:[NSDate date]];
    [imagePost setLocation:[[Profile sharedProfile] lastLocation]];
    [imagePost setUser:[[Profile sharedProfile] user]];
    [imagePost setImage:a_picture];
    [m_imagePostArray addObject:imagePost];
    
    
    UIImageView * photoImageView = [[UIImageView alloc] init];
    [m_photoArray addObject:photoImageView];
    [photoImageView setImage:a_picture];
    float pictureDimension = m_photoView.frame.size.height - 2*kPictureYOffset;
    float pictureX = ([m_photoArray count] - 1) * (pictureDimension + kPictureXOffset) + kPictureXOffset;
    [photoImageView setFrame:CGRectMake(pictureX, kPictureYOffset, pictureDimension, pictureDimension)];
    [m_photoScrollView addSubview:photoImageView];
    [m_photoScrollView setContentSize:CGSizeMake(pictureX + pictureDimension + kPictureXOffset, m_photoView.frame.size.height)];
    [m_photoScrollView scrollRectToVisible:CGRectMake(photoImageView.frame.origin.x + kPictureXOffset, photoImageView.frame.origin.y, photoImageView.frame.size.width, photoImageView.frame.size.height) animated:YES];
    
    [photoImageView setUserInteractionEnabled:YES];
    
    //Add Swipe Gesture Recognizer
    UISwipeGestureRecognizer * swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pictureDidSwipe:)];
    [swipeGestureRecognizer setDelegate:self];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [photoImageView addGestureRecognizer:swipeGestureRecognizer];
    
    //Add Tap Gesture Recognizer
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureDidTap:)];
    [tapGestureRecognizer setDelegate:self];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [photoImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)pictureDidSwipe:(UIGestureRecognizer *)a_gestureRecognizer
{
    for(int i = 0; i < [m_photoArray count]; i++)
    {
        if([a_gestureRecognizer.view isEqual:[m_photoArray objectAtIndex:i]])
        {
            [self removePhotoAtIndex:i];
            break;
        }
    }
}

- (void)removePhotoAtIndex:(NSInteger)a_index
{
    UIImageView * photoView = [m_photoArray objectAtIndex:a_index];
    
    //@todo(jdiprete): drag off screen instead of animating
    [UIView animateWithDuration:0.3 animations:^(void)
     {
         [photoView setFrame:CGRectMake(photoView.frame.origin.x, [UIScreen mainScreen].bounds.size.height, photoView.frame.size.width, photoView.frame.size.height)];
     } completion:^(BOOL finished)
     {
         [photoView removeFromSuperview];
         [m_photoArray removeObjectAtIndex:a_index];
         [m_imagePostArray removeObjectAtIndex:a_index];
         [self updatePhotosFromIndex:a_index];
     }];
}

- (void)updatePhotosFromIndex:(NSInteger)a_index
{
    for(int i = a_index; i < [m_photoArray count]; i++)
    {
        UIImageView * photoView = [m_photoArray objectAtIndex:i];
        [UIView animateWithDuration:0.3 animations:^(void)
         {
             [photoView setFrame:CGRectMake(photoView.frame.origin.x - photoView.frame.size.width - kPictureXOffset, photoView.frame.origin.y, photoView.frame.size.width, photoView.frame.size.height)];
         }];
    }
    float pictureDimension = m_photoView.frame.size.height - 2*kPictureYOffset;
    [m_photoScrollView setContentSize:CGSizeMake([m_photoArray count] * (pictureDimension + kPictureXOffset), m_photoView.frame.size.height)];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - IBActions

- (IBAction)cameraDonePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePicturePressed:(id)sender
{
    [self takePicture];
}

- (IBAction)postPressed:(id)sender
{
    for(ImagePost * imagePost in m_imagePostArray)
    {
        [m_event addPost:imagePost];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self addPhotoToView:picture];
}

@end

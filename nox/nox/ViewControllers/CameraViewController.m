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
#import "Profile.h"
#import "UIPlaceHolderTextView.h"
#import "Util.h"

@interface CameraViewController ()

@end

static const float kPictureYOffset = 10.0;
static const float kPictureXOffset = 10.0;

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
    
    m_flashMode = UIImagePickerControllerCameraFlashModeAuto;
    
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
    
    [m_pictureImageView setImage:[m_currentImagePost image]];
    [m_pictureDetailView setFrame:self.view.frame];
    [m_photoView removeFromSuperview];
    [m_pictureDetailView addSubview:m_photoView];
    [self.view addSubview:m_pictureDetailView];
}

- (void)switchToCameraPressed:(id)sender
{
    [self switchToCamera];
}

- (void)switchToCamera
{
    m_currentImagePost = nil;
    [m_photoView removeFromSuperview];
    [m_pictureDetailView removeFromSuperview];
    [self.view addSubview:m_photoView];
}

#pragma mark - Photo View Methods



- (void)addPhotoToView:(UIImage *)a_picture
{
    //Create the image post
    ImagePost * imagePost = [[ImagePost alloc] init];
    [imagePost setTime:[NSDate date]];
    [imagePost setLocation:[[Profile sharedProfile] lastLocation]];
    [imagePost setUser:[[Profile sharedProfile] user]];
    [imagePost setEvent:[m_event resourceURI]];
    [imagePost setType:kImageType];
    [imagePost setImage:a_picture];
    [m_imagePostArray addObject:imagePost];
    
    
    UIImageView * photoImageView = [[UIImageView alloc] init];
    [m_photoArray addObject:photoImageView];
    
    float pictureDimension = m_photoView.frame.size.height - 2*kPictureYOffset;
    
    //resize picture to save memory
    float deviceScale = [[UIScreen mainScreen] scale];
    a_picture = [Util resizeImage:a_picture toSize:CGSizeMake(pictureDimension * deviceScale, pictureDimension * deviceScale)];
    
    [photoImageView setImage:a_picture];

    float pictureX = ([m_photoArray count] - 1) * (pictureDimension + kPictureXOffset) + kPictureXOffset;
    [photoImageView setFrame:CGRectMake(pictureX, kPictureYOffset, pictureDimension, pictureDimension)];
    [m_photoScrollView addSubview:photoImageView];
    [m_photoScrollView setContentSize:CGSizeMake(pictureX + pictureDimension + kPictureXOffset, m_photoView.frame.size.height)];
    [m_photoScrollView scrollRectToVisible:CGRectMake(photoImageView.frame.origin.x + kPictureXOffset, photoImageView.frame.origin.y, photoImageView.frame.size.width, photoImageView.frame.size.height) animated:YES];
    
    [photoImageView setUserInteractionEnabled:YES];
    
    //Add Pan Gesture Recognizer to delete pictures
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPicture:)];
    [panGestureRecognizer setDelegate:self];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [photoImageView addGestureRecognizer:panGestureRecognizer];
    
    //Add Tap Gesture Recognizer
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureDidTap:)];
    [tapGestureRecognizer setDelegate:self];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [photoImageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)dragPicture:(UIGestureRecognizer *)a_gestureRecognizer
{
    UIView * picture = [a_gestureRecognizer view];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)a_gestureRecognizer translationInView:self.view];
    
    if([(UIPanGestureRecognizer *)a_gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        m_pictureDragY = picture.frame.origin.y;
	}
	
	translatedPoint = CGPointMake(picture.frame.origin.x, m_pictureDragY + translatedPoint.y);
	
    if(translatedPoint.y < kPictureYOffset)
    {
        [picture setFrame:CGRectMake(translatedPoint.x, kPictureYOffset, picture.frame.size.width, picture.frame.size.height)];
    }
    else
    {
        [picture setFrame:CGRectMake(translatedPoint.x, translatedPoint.y, picture.frame.size.width, picture.frame.size.height)];
    }
	
	if([(UIPanGestureRecognizer*)a_gestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        float velocity = [(UIPanGestureRecognizer*)a_gestureRecognizer velocityInView:self.view].y;
        
        float finalY = translatedPoint.y;
        
        if(velocity < 0) //moving up
        {
            finalY = kPictureYOffset;
        }
        else // moving down
        {
            if(translatedPoint.y > kPictureYOffset + (([picture superview].frame.size.height - kPictureYOffset)*.3))
            {
                finalY = [picture superview].frame.size.height;
            }
            else
            {
                finalY = kPictureYOffset;
            }
		}

		[UIView commitAnimations];
        [UIView animateWithDuration:0.2 animations:^
         {
             [picture setFrame:CGRectMake(translatedPoint.x, finalY, picture.frame.size.width, picture.frame.size.height)];
         }completion:^(BOOL finished)
         {
             //If the picture is off the screen, delete it
             if(picture.frame.origin.y >= [picture superview].frame.size.height)
             {
                 for(int i = 0; i < [m_photoArray count]; i++)
                 {
                     if([picture isEqual:[m_photoArray objectAtIndex:i]])
                     {
                         //if we delete the one we're editing, go back to the camera
                         if([[(ImagePost *)[m_imagePostArray objectAtIndex:i] image] isEqual:[m_currentImagePost image]])
                         {
                             [self switchToCamera];
                         }
                         [picture removeFromSuperview];
                         [m_photoArray removeObjectAtIndex:i];
                         [m_imagePostArray removeObjectAtIndex:i];
                         [self updatePhotosFromIndex:i];
                         break;
                     }
                 }
             }
         }];
    }
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
    //don't open picture when it's being dragged off screen
    if(([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        || ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]))
    {
        return NO;
    }
    return YES;
}

#pragma mark - IBActions

- (IBAction)toggleFlash:(id)sender
{
    switch (m_flashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            m_flashMode = UIImagePickerControllerCameraFlashModeOff;
            [m_flashButton setBackgroundImage:[UIImage imageNamed:@"flashOffButton.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOff:
            m_flashMode = UIImagePickerControllerCameraFlashModeOn;
            [m_flashButton setBackgroundImage:[UIImage imageNamed:@"flashOnButton.png"] forState:UIControlStateNormal];
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            m_flashMode = UIImagePickerControllerCameraFlashModeAuto;
            [m_flashButton setBackgroundImage:[UIImage imageNamed:@"flashAutoButton.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self setCameraFlashMode:m_flashMode];
}

- (IBAction)cameraDonePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePicturePressed:(id)sender
{
    [self takePicture];
}

- (void)disableView
{
    [self.view setUserInteractionEnabled:NO];
}

- (void)enableView
{
    [self.view setUserInteractionEnabled:YES];
}

- (IBAction)postPressed:(id)sender
{
    [self disableView];

    for(ImagePost * imagePost in m_imagePostArray)
    {
        [m_event addPost:imagePost];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPostDidSucceed:) name:kAddPostDidSucceedNotification object:imagePost];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPostDidFail:) name:kAddPostDidFailNotification object:imagePost];
    }
}

- (void)addPostDidSucceed:(NSNotification *)a_notification
{
    ImagePost * imagePost = [a_notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidSucceedNotification object:imagePost];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidFailNotification object:imagePost];
    
    [m_imagePostArray removeObject:imagePost];
    //dismiss the view when all images have been successfully posted
    if([m_imagePostArray count] == 0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addPostDidFail:(NSNotification *)a_notification
{
    //@todo(jdiprete): do something to tell them why it failed...
    ImagePost * imagePost = [a_notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidSucceedNotification object:imagePost];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddPostDidFailNotification object:imagePost];
    [self enableView];
}

- (IBAction)switchCameraViewPressed:(id)sender
{
    if([self cameraDevice] == UIImagePickerControllerCameraDeviceFront)
    {
        [self setCameraDevice:UIImagePickerControllerCameraDeviceRear];
    }
    else
    {
        [self setCameraDevice:UIImagePickerControllerCameraDeviceFront];
    }
}

#pragma mark - UIImagePickerController Delegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGRect cropRect;
    
    //landscape
    if(picture.imageOrientation == UIImageOrientationDown || picture.imageOrientation == UIImageOrientationUp)
    {
        float pictureScale = picture.size.height/[UIScreen mainScreen].bounds.size.width;
        //@todo(jdiprete): don't hardcode these numbers, grab them from the overlay
        cropRect = CGRectMake(60 * pictureScale, 10 * pictureScale, kImageDimension * pictureScale, kImageDimension * pictureScale);
    }
    //portrait
    else
    {
        float pictureScale = picture.size.width/[UIScreen mainScreen].bounds.size.width;
        cropRect = CGRectMake(60 * pictureScale, 10 * pictureScale, kImageDimension * pictureScale, kImageDimension * pictureScale);
    }
    CGImageRef pictureRef = CGImageCreateWithImageInRect([picture CGImage], cropRect);
    picture = [UIImage imageWithCGImage:pictureRef scale:picture.scale orientation:picture.imageOrientation];
    
    //scale this down to save memory
    //@todo(jdiprete): If we want to give the option of saving to camera roll, do that before scaling the images down
    float deviceResolution = [[UIScreen mainScreen] scale];
    picture = [Util resizeImage:picture toSize:CGSizeMake(kImageDimension * deviceResolution, kImageDimension * deviceResolution)];
    
    [self addPhotoToView:picture];
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

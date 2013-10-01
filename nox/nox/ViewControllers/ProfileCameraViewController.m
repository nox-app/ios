//
//  ProfileCameraViewController.m
//  nox
//
//  Created by Justine DiPrete on 9/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "ProfileCameraViewController.h"

#import "Constants.h"
#import "Util.h"

@interface ProfileCameraViewController ()

@end

@implementation ProfileCameraViewController

@synthesize profileDelegate = m_profileDelegate;

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
    
    m_flashMode = UIImagePickerControllerCameraFlashModeAuto;
    
    [self setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    [self setCameraDevice:UIImagePickerControllerCameraDeviceFront];
    [self setShowsCameraControls:NO];
    [self setNavigationBarHidden:YES];
    [self setToolbarHidden:YES];
    [self setWantsFullScreenLayout:YES];
    [self setDelegate:self];
    
    UIView * cameraOverlay = [[[NSBundle mainBundle] loadNibNamed:@"ProfileCameraOverlayView" owner:self options:nil] objectAtIndex:0];
    
    [self setCameraOverlayView:cameraOverlay];
}

#pragma mark - IBActions

- (IBAction)takePicturePressed:(id)sender
{
    [self takePicture];
}

- (IBAction)usePicturePressed:(id)sender
{
    float deviceResolution = [[UIScreen mainScreen] scale];
    m_currentPicture = [Util resizeImage:m_currentPicture toSize:CGSizeMake(kImageDimension * deviceResolution, kImageDimension * deviceResolution)];
    [m_profileDelegate setProfilePicture:m_currentPicture];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retakePicturePressed:(id)sender
{
    [m_previewView removeFromSuperview];
}

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //flip the picture if it's the front camera
    if([self cameraDevice] == UIImagePickerControllerCameraDeviceFront)
    {
        //Flip the image
        picture = [UIImage imageWithCGImage:picture.CGImage scale:picture.scale orientation:UIImageOrientationLeftMirrored];
    }
    
    CGRect cropRect;
    
    //landscape
    if(picture.imageOrientation == UIImageOrientationDown || picture.imageOrientation == UIImageOrientationUp)
    {
        float pictureScale = picture.size.height/[UIScreen mainScreen].bounds.size.width;
        //@todo(jdiprete): don't hardcode these numbers, grab them from the overlay
        cropRect = CGRectMake(60 * pictureScale, 10 * pictureScale, 310 * pictureScale, 310 * pictureScale);
    }
    //portrait
    else
    {
        float pictureScale = picture.size.width/[UIScreen mainScreen].bounds.size.width;
        cropRect = CGRectMake(60 * pictureScale, 10 * pictureScale, 310 * pictureScale, 310 * pictureScale);
    }
    CGImageRef pictureRef = CGImageCreateWithImageInRect([picture CGImage], cropRect);
    picture = [UIImage imageWithCGImage:pictureRef scale:picture.scale orientation:picture.imageOrientation];
    
    m_currentPicture = picture;
    [self displayPreview];
}

- (void)displayPreview
{
    [m_profileImageView setImage:m_currentPicture];
    [self.view addSubview:m_previewView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

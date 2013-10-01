//
//  EditProfileViewController.m
//  nox
//
//  Created by Justine DiPrete on 9/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "EditProfileViewController.h"

#import "Constants.h"
#import "Profile.h"
#import "ProfileCameraViewController.h"
#import "User.h"
#import "Util.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

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
    
    [m_iconView setImage:[[[Profile sharedProfile] user] icon]];
}

- (IBAction)donePressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editIconPressed:(id)sender
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Profile Picture Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < 2)
    {
        if(buttonIndex == 0)
        {
            ProfileCameraViewController * profileCameraViewController = [[ProfileCameraViewController alloc] init];
            [profileCameraViewController setProfileDelegate:self];
            [self presentViewController:profileCameraViewController animated:YES completion:nil];
        }
        else if(buttonIndex == 1)
        {
            //@todo(jdiprete): make this better
            UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
            [imagePickerController setDelegate:self];
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}

- (void)setProfilePicture:(UIImage *)a_image
{
    [m_iconView setImage:a_image];
    [[[Profile sharedProfile] user] updateIcon:a_image];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * picture = [info objectForKey:UIImagePickerControllerOriginalImage];
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
    
    float deviceResolution = [[UIScreen mainScreen] scale];
    picture = [Util resizeImage:picture toSize:CGSizeMake(kImageDimension * deviceResolution, kImageDimension * deviceResolution)];
    
    [m_iconView setImage:picture];
    [[[Profile sharedProfile] user] updateIcon:picture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

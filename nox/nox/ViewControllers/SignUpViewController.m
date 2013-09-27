//
//  SignUpViewController.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "SignUpViewController.h"

#import "Constants.h"
#import "PictureNameTableViewCell.h"
#import "Profile.h"
#import "TextFieldCell.h"
#import "User.h"

@interface SignUpViewController ()

@end

static NSString * const kPictureNameCellReuseIdentifier = @"PictureNameCellReuseIdentifier";
static NSString * const kTextFieldCellReuseIdentifier = @"TextFieldCellReuseIdentifier";

@implementation SignUpViewController

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
    
    [self.view setBackgroundColor:[Constants noxColor]];
    
    m_nameTableView = [[UITableView alloc] init];
    [m_nameTableView setDelegate:self];
    [m_nameTableView setDataSource:self];
    [m_nameTableView setScrollEnabled:NO];
    
    [m_nameTableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kTextFieldCellReuseIdentifier];
    [m_tableView registerNib:[UINib nibWithNibName:@"TextViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kTextFieldCellReuseIdentifier];

    [m_tableView registerNib:[UINib nibWithNibName:@"PictureNameTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kPictureNameCellReuseIdentifier];
    m_placeHolderTextArray = [NSArray arrayWithObjects:@"Email", @"Phone Number", @"Birthday", @"Password", nil];
    m_namePlaceHolderArray = [NSArray arrayWithObjects:@"First Name", @"Last Name", nil];
    m_tableView.layer.cornerRadius = 5.0;
    
    UITapGestureRecognizer * tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpPressed:(id)sender
{
    [self createUser];
}

- (void)createUser
{
    //@todo(jdiprete): validate and whatnot
    NSString * firstName = ((TextFieldCell *)[m_nameTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text;
    NSString * lastName = ((TextFieldCell *)[m_nameTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text;
    NSString * email = ((TextFieldCell *)[m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text;
    NSString * phoneNumber = ((TextFieldCell *)[m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).textField.text;
    NSString * password = ((TextFieldCell *)[m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]]).textField.text;
    
    m_user = [[User alloc] init];
    [m_user setFirstName:firstName];
    [m_user setLastName:lastName];
    [m_user setEmail:email];
    [m_user setPhoneNumber:phoneNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreationDidSucceed:) name:kUserCreationDidSucceedNotification object:m_user];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userCreationDidFail:) name:kUserCreationDidFailNotification object:m_user];
    [m_user saveWithPassword:password];
    
}

- (void)userCreationDidSucceed:(NSNotification *)a_notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserCreationDidFailNotification object:m_user];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserCreationDidSucceedNotification object:m_user];
    
    [[Profile sharedProfile] setUser:m_user];
    m_user = nil;
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)userCreationDidFail:(NSNotification *)a_notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserCreationDidFailNotification object:m_user];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserCreationDidSucceedNotification object:m_user];
    m_user = nil;
}

#pragma mark - Profile Picture Methods

- (void)pictureDidTap:(UIGestureRecognizer *)a_gestureRecognizer
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose from Library", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex < 2)
    {
        UIImagePickerController * imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setDelegate:self];
        if(buttonIndex == 0)
        {
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imagePickerController setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
            [imagePickerController setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        }
        else if(buttonIndex == 1)
        {
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //@todo(jdiprete): handle all the crop stuff
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];

    PictureNameTableViewCell * cell = (PictureNameTableViewCell *)[m_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.pictureImageView setImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([tableView isEqual:m_nameTableView])
    {
        return [m_namePlaceHolderArray count];
    }
    return [m_placeHolderTextArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:m_nameTableView])
    {
        TextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellReuseIdentifier];
        if(cell == nil)
        {
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextFieldCellReuseIdentifier];
        }
        
        UIView * paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, [TextFieldCell height])];
        cell.textField.leftView = paddingView;
        cell.textField.leftViewMode = UITextFieldViewModeAlways;
        [cell.textField setDelegate:self];
        
        [cell.textField setPlaceholder:[m_namePlaceHolderArray objectAtIndex:indexPath.row]];
        return cell;
    }
    else
    {
        if(indexPath.row > kSignUpNameField)
        {
            TextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTextFieldCellReuseIdentifier];
            }
            
            UIView * paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, [TextFieldCell height])];
            cell.textField.leftView = paddingView;
            cell.textField.leftViewMode = UITextFieldViewModeAlways;
            [cell.textField setDelegate:self];
            
            if(indexPath.row == kSignUpPasswordField)
            {
                [cell.textField setSecureTextEntry:YES];
            }
            
            [cell.textField setPlaceholder:[m_placeHolderTextArray objectAtIndex:indexPath.row - 1]];
            
            return cell;
        }
        else
        {
            PictureNameTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kPictureNameCellReuseIdentifier];
            if(cell == nil)
            {
                cell = [[PictureNameTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPictureNameCellReuseIdentifier];
            }
            
            [m_nameTableView setFrame:CGRectMake(0, 0, cell.nameView.frame.size.width, cell.nameView.frame.size.height)];
            if(![[m_nameTableView superview] isEqual:cell])
            {
                [cell.nameView addSubview:m_nameTableView];
            }
            
            UITapGestureRecognizer * imageTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureDidTap:)];
            [cell.pictureImageView addGestureRecognizer:imageTapGestureRecognizer];
            
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:m_nameTableView])
    {
        return [TextFieldCell height];
    }
    else
    {
        if(indexPath.row == 0)
        {
            return [TextFieldCell height] * 2;
        }
        return [TextFieldCell height];
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if([textField isEqual:m_passwordTextField])
//    {
//        [self login];
//    }
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    m_currentFirstResponder = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard
{
    [m_currentFirstResponder resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view.superview isKindOfClass:[UIToolbar class]])
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

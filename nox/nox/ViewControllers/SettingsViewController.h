//
//  SettingsViewController.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingViewControllerDelegate.h"

@class  Switchy;

@interface SettingsViewController : UIViewController
{
    id<SettingViewControllerDelegate> m_delegate;
    
    Switchy * m_publicPrivateSwitch;
    Switchy * m_saveOriginalImagesSwitch;
    Switchy * m_saveProcessedImagesSwitch;
}

@property id<SettingViewControllerDelegate> delegate;

- (IBAction)donePressed:(id)sender;
- (IBAction)logoutPressed:(id)sender;
- (IBAction)editProfilePressed:(id)sender;

@end

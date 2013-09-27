//
//  EventSettingsViewControllerDelegate.h
//  nox
//
//  Created by Justine DiPrete on 9/15/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventSettingsViewControllerDelegate <NSObject>

- (void)dismissViewController;
- (void)updateEvent;

@end

//
//  AppDelegate.h
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRNavigationController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL m_userDidDownload;
    BOOL m_splashTimerDidComplete;
}

@property (strong, nonatomic) UIWindow * window;
@property CRNavigationController * navigationController;

@end

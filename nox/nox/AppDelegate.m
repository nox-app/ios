//
//  AppDelegate.m
//  nox
//
//  Created by Justine DiPrete on 6/29/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "AppDelegate.h"

#import "CRNavigationController.h"
#import "EventsViewController.h"
#import "FriendsMenuViewController.h"
#import "KeychainItemWrapper.h"
#import "LoginViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "Profile.h"
#import "SplashScreenViewController.h"
#import "User.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    EventsViewController * eventsViewController = [[EventsViewController alloc] init];
    
    self.navigationController = [[CRNavigationController alloc] initWithRootViewController:eventsViewController];
    
    FriendsMenuViewController * friendsMenuViewController = [[FriendsMenuViewController alloc] init];
    
    MFSideMenuContainerViewController * container = [MFSideMenuContainerViewController containerWithCenterViewController:self.navigationController leftMenuViewController:nil rightMenuViewController:friendsMenuViewController];
    
    [self.window setRootViewController:container];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    KeychainItemWrapper * keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"NoxLogin" accessGroup:nil];
    NSString * apiKey = [keychainItem objectForKey:(__bridge id)kSecValueData];
    NSString * email = [keychainItem objectForKey:(__bridge id)kSecAttrAccount];
    NSString * resourceURI = [keychainItem objectForKey:(__bridge id)kSecAttrDescription];
    NSLog(@"API: %@ EMAIL: %@ RESOURCE: %@", apiKey, email, resourceURI);
    
    if([email isEqualToString:@""])
    {
        LoginViewController * loginViewController = [[LoginViewController alloc] init];
        [self.navigationController presentViewController:loginViewController animated:NO completion:nil];
    }
    else
    {
        SplashScreenViewController * splashScreenViewController = [[SplashScreenViewController alloc] init];
        [self.navigationController presentViewController:splashScreenViewController animated:NO completion:nil];
        
        [[Profile sharedProfile] setApiKey:apiKey];
        
        User * user = [[User alloc] initWithEmail:email];
        [[Profile sharedProfile] setUser:user];
        
        [user downloadUserWithResourceURI:resourceURI];
        [self performSelector:@selector(dismissSplashScreen) withObject:nil afterDelay:3.0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidDownload) name:kUserDownloadDidSucceedNotification object:nil];
        
    }
    
    return YES;
}

- (void)dismissSplashScreen
{
    m_splashTimerDidComplete = YES;
    if(m_userDidDownload)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)userDidDownload
{
    m_userDidDownload = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUserDownloadDidSucceedNotification object:nil];
    if(m_splashTimerDidComplete)
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//
//  AppDelegate.m
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "OnlineMovieDatabase.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setStyles];
    
    // Override point for customization after application launch.
    [TestFlight takeOff:@"bd44b4d15d82ebee20573cbad8c85c83_MzE1MTMyMDExLTExLTA1IDEzOjA0OjU2LjU3ODE3Mg"];
    
    [[OnlineMovieDatabase sharedMovieDatabase] setApiKey:@"d518563ee67cb6d475d2440d3e663e93"];
    
    
    
    return YES;
}

- (void)setStyles
{
    // UINavigationBar
    UIImage *navigationBarBgImage = [[UIImage imageNamed:@"g_bg_navbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBgImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      HEXColor(0x636875), 
      UITextAttributeTextColor, 
      [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f], 
      UITextAttributeTextShadowColor, 
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], 
      UITextAttributeTextShadowOffset, 
      [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f], 
      UITextAttributeFont, 
      nil]];
    
    // UIToolbar
    [[UIToolbar appearance] setBackgroundImage:navigationBarBgImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // UIBarButtonItem
    UIImage *barButtonBgInage = [[UIImage imageNamed:@"g_barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonBgInage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      HEXColor(0xFFFFFF), 
      UITextAttributeTextColor, 
      [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.40f], 
      UITextAttributeTextShadowColor, 
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], 
      UITextAttributeTextShadowOffset, 
      [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f], 
      UITextAttributeFont, 
      nil] forState:UIControlStateNormal];
    
    // UISearchBar
    [[UISearchBar appearance] setBackgroundImage:navigationBarBgImage];
    
    // UISegmentedControl
    //[[UISegmentedControl appearance] setBackgroundImage:navigationBarBgImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end

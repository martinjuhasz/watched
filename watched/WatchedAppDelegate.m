//
//  AppDelegate.m
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WatchedAppDelegate.h"
#import "OnlineMovieDatabase.h"

#import "UIViewController+MJPopupViewController.h"
#import "MJCustomTableViewCell.h"
#import "WatchedWebBrowser.h"
#import "AddMovieViewController.h"
#import "MJInternetConnection.h"
#import "WatchedWebBrowser.h"
#import "MJWatchedNavigationBar.h"
#import <MessageUI/MessageUI.h>
#import "TestFlight.h"
#import "MoviePopupViewController.h"
#import "UIResponder+KeyboardCache.h"
#import <Social/Social.h>
#import "MJWatchedNavigationController.h"
#import "WatchedStyledViewController.h"

@interface WatchedAppDelegate ()<AddMovieViewDelegate, MoviePopupViewControllerDelegate> {
}
@end


@implementation WatchedAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setStyles];
    [MJInternetConnection sharedInternetConnection];
    [UIResponder cacheKeyboard:YES];
    
    [self startTestFlight];
    
    [[OnlineMovieDatabase sharedMovieDatabase] setApiKey:@"d518563ee67cb6d475d2440d3e663e93"];
    [[OnlineMovieDatabase sharedMovieDatabase] setPreferredLanguage:[self appLanguage]];
    
    return YES;
}

- (NSString*)appLanguage
{
    NSString *userLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([userLanguage isEqualToString:@"de"])
        return @"de";

    return @"en";
}

- (void)startTestFlight
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isDisabled = [standardUserDefaults boolForKey:OPTOUT_SETTINGS];
    if(!isDisabled) {
        [TestFlight takeOff:@"bd44b4d15d82ebee20573cbad8c85c83_MzE1MTMyMDExLTExLTA1IDEzOjA0OjU2LjU3ODE3Mg"];
    }
}

- (void)setStyles
{
    
    // UINavigationBar
    UIImage *navigationBarBgImage = [[UIImage imageNamed:@"g_bg_navbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *navigationBarBgImageLS = [[UIImage imageNamed:@"g_bg_navbar_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [[UINavigationBar appearanceWhenContainedIn:[MJWatchedNavigationController class] , nil] setBackgroundImage:navigationBarBgImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[WatchedStyledViewController class] , nil] setBackgroundImage:navigationBarBgImage forBarMetrics:UIBarMetricsDefault];

    // Bar Button Items
    id navBarButtonAppearance1 = [UIBarButtonItem appearanceWhenContainedIn:[MJWatchedNavigationController class], nil];
    id navBarButtonAppearance2 = [UIBarButtonItem appearanceWhenContainedIn:[WatchedStyledViewController class], nil];
    [self setStylesForBarButtonItem:navBarButtonAppearance1];
    [self setStylesForBarButtonItem:navBarButtonAppearance2];
    
    [[UINavigationBar appearance] setBackgroundImage:navigationBarBgImageLS forBarMetrics:UIBarMetricsLandscapePhone];
    
    
    // UINavigationBar Popover
    UIImage *navigationPopoverBarBgImage = [[UIImage imageNamed:@"pv_bg_navbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16.0f, 12.0f, 7.0f, 12.0f)];
     [[UINavigationBar appearanceWhenContainedIn:[AddMovieViewController class], nil] setBackgroundImage:navigationPopoverBarBgImage forBarMetrics:UIBarMetricsDefault];
    [[UIToolbar appearanceWhenContainedIn:[AddMovieViewController class], nil] setBackgroundImage:navigationPopoverBarBgImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    
    NSDictionary *navBarTitleStyles = [NSDictionary dictionaryWithObjectsAndKeys:
                                       HEXColor(0xFFFFFF),
                                       UITextAttributeTextColor,
                                       [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f],
                                       UITextAttributeTextShadowColor,
                                       [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                       UITextAttributeTextShadowOffset, 
                                       [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                       UITextAttributeFont, 
                                       nil];
    
    [[UINavigationBar appearanceWhenContainedIn:[MJWatchedNavigationController class], nil] setTitleTextAttributes:navBarTitleStyles];
    [[UINavigationBar appearanceWhenContainedIn:[WatchedStyledViewController class], nil] setTitleTextAttributes:navBarTitleStyles];
    
    // UIToolbar
    UIImage *browserBarBgImage = [[UIImage imageNamed:@"g_browser.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIToolbar appearance] setBackgroundImage:navigationBarBgImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearanceWhenContainedIn:[WatchedWebBrowser class], nil] setBackgroundImage:browserBarBgImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // UISearchBar
    [[UISearchBar appearanceWhenContainedIn:[MJWatchedNavigationController class], nil] setBackgroundImage:navigationBarBgImage];
    [[UISearchBar appearanceWhenContainedIn:[WatchedStyledViewController class], nil] setBackgroundImage:navigationBarBgImage];
    
    // TableView
    [[UITableView appearance] setBackgroundColor:HEXColor(DEFAULT_COLOR_BG)];
    [[UITableView appearance] setSeparatorColor:HEXColor(0x737373)];
    [[UITableView appearance] setSeparatorColor:HEXColor(0x1C1C1C)];
    
    // UISegmentedControl
    UIImage *segmentedControlBgImage = [[UIImage imageNamed:@"mv_segmented.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *segmentedControlBgImageActive = [[UIImage imageNamed:@"mv_segmented_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
    UIImage *segmentedDividerNN = [UIImage imageNamed:@"mv_segmented-dv-nn.png"];
    UIImage *segmentedDividerAN = [UIImage imageNamed:@"mv_segmented-dv-an.png"];
    UIImage *segmentedDividerNA = [UIImage imageNamed:@"mv_segmented-dv-na.png"];
    [[UISegmentedControl appearance] setBackgroundImage:segmentedControlBgImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:segmentedControlBgImageActive forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentedDividerNN forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentedDividerAN forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:segmentedDividerNA forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 HEXColor(0xFFFFFF),
                                                 UITextAttributeTextColor,
                                                 [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f],
                                                 UITextAttributeTextShadowColor,
                                                 [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                 UITextAttributeTextShadowOffset,
                                                 [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f],
                                                 UITextAttributeFont,
                                                 nil] forState:UIControlStateNormal];
    
    // UISwitch
    [[UISwitch appearance] setOnImage:[UIImage imageNamed:@"g_uiswitch_bg_on.png"]];
}

- (void)setStylesForBarButtonItem:(id)itemAppearance
{
    
    UIImage *navigationBarBackBgImage = [[UIImage imageNamed:@"g_backbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 4)];
    UIImage *navigationBarBackBgImageLS = [[UIImage imageNamed:@"g_backbutton_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 4)];
    UIImage *navigationBarBackBgImageActive = [[UIImage imageNamed:@"g_backbutton_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 4)];
    UIImage *navigationBarBackBgImageActiveLS = [[UIImage imageNamed:@"g_backbutton_landscape_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 4)];
    
    [itemAppearance setBackButtonBackgroundImage:navigationBarBackBgImage
                                                forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [itemAppearance setBackButtonBackgroundImage:navigationBarBackBgImageActive
                                                forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [itemAppearance setBackButtonBackgroundImage:navigationBarBackBgImageLS
                                                forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [itemAppearance setBackButtonBackgroundImage:navigationBarBackBgImageActiveLS
                                                forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
    
    // UIBarButtonItem
    UIImage *barButtonBgImage = [[UIImage imageNamed:@"g_barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    UIImage *barButtonBgImageActive = [[UIImage imageNamed:@"g_barbutton_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    [itemAppearance setBackgroundImage:barButtonBgImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [itemAppearance setBackgroundImage:barButtonBgImageActive forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [itemAppearance setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      HEXColor(0xFFFFFF),
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f],
      UITextAttributeFont,
      nil] forState:UIControlStateNormal];
    
    // landscape
    [itemAppearance setBackButtonBackgroundImage:navigationBarBackBgImageLS forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    [itemAppearance setBackButtonBackgroundImage:navigationBarBackBgImageActiveLS forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *serverIDString = [url host];
    if(!serverIDString) return NO;
    
    int serverID = [serverIDString intValue];
    if(!serverID || serverID <= 0) return NO;
    
    if(![self.window.rootViewController.view viewWithTag:23942]) {
        [self displayPopupViewWithMovieNumber:[NSNumber numberWithInt:serverID]];
    } else {
        [self.window.rootViewController dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom completion:^{
            [self displayPopupViewWithMovieNumber:[NSNumber numberWithInt:serverID]];
        }];
    }
    
    return YES;
}

- (void)displayPopupViewWithMovieNumber:(NSNumber*)movieNumber
{
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    addController = nil;
//    addController = (AddMovieViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"AddMovieViewController"];
//    addController.delegate = self;
//    addController.resultID = movieNumber;
//    
//    if(self.window.rootViewController.modalViewController) {
//        [self.window.rootViewController dismissModalViewControllerAnimated:NO];
//    }
//    
//    [self.window.rootViewController presentPopupViewController:addController animationType:PopupViewAnimationSlideBottomBottom];
    
    MoviePopupViewController *popupViewController = [[MoviePopupViewController alloc ] init];
    popupViewController.resultID = movieNumber;
    popupViewController.delegate = self;
    
    if([self.window.rootViewController.presentedViewController isKindOfClass:[MoviePopupViewController class]]) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    [self.window.rootViewController presentPopupViewController:popupViewController animationType:PopupViewAnimationSlideBottomBottom];
    
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AddMovieViewDelegate

//- (void)AddMovieControllerCancelButtonClicked:(AddMovieViewController *)addMovieViewController
//{
//    [self.window.rootViewController dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom completion:nil];
//    addController = nil;
////    [self.window.rootViewController.navigationController popToRootViewControllerAnimated:YES];
//    
//}

- (void)moviePopupCancelButtonClicked:(MoviePopupViewController *)moviePopupViewController
{
    [self.window.rootViewController dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom completion:nil];
}

@end

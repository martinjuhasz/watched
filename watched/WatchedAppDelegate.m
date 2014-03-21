//
//  AppDelegate.m
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "WatchedAppDelegate.h"
#import "OnlineMovieDatabase.h"

#import "UIViewController+MJPopupViewController.h"
#import "MJCustomTableViewCell.h"
#import "WatchedWebBrowser.h"
#import "MJInternetConnection.h"
#import "WatchedWebBrowser.h"
#import "MJWatchedNavigationBar.h"
#import <MessageUI/MessageUI.h>
#import "UIResponder+KeyboardCache.h"
#import <Social/Social.h>
#import "MJWatchedNavigationController.h"
#import "WatchedStyledViewController.h"
#import "OnlineDatabaseBridge.h"
#import "AFJSONRequestOperation.h"
#import "MJUWatchedStyle.h"
#import <HockeySDK/HockeySDK.h>

@interface WatchedAppDelegate () {
}


@end

@implementation WatchedAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MJUWatchedStyle setupDefaultStyle];
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"a6619c8d0d092c150c4a5555ae7f14cb"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    
    [MJInternetConnection sharedInternetConnection];
    [UIResponder cacheKeyboard:YES];
    
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
//    NSString *serverIDString = [url host];
//    if(!serverIDString) return NO;
//    
//    int serverID = [serverIDString intValue];
//    if(!serverID || serverID <= 0) return NO;
//    
//    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
//    AFJSONRequestOperation *operation = [bridge saveMovieForID:[NSNumber numberWithInt:serverID] completion:^(Movie *movie) {
//        
//    } failure:^(NSError *error) {
//        DebugLog("%@", [error localizedDescription]);
//    }];
//    [operation start];
//    
//    return YES;
    return NO;
}

@end

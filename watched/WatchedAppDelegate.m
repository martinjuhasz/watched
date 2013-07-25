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
#import "AddMovieViewController.h"
#import "MJInternetConnection.h"
#import "WatchedWebBrowser.h"
#import "MJWatchedNavigationBar.h"
#import <MessageUI/MessageUI.h>
#import "TestFlight.h"
#import "UIResponder+KeyboardCache.h"
#import <Social/Social.h>
#import "MJWatchedNavigationController.h"
#import "WatchedStyledViewController.h"
#import "UISS.h"
#import <Crashlytics/Crashlytics.h>
#import "OnlineDatabaseBridge.h"
#import "AFJSONRequestOperation.h"

@interface WatchedAppDelegate ()<AddMovieViewDelegate> {
}

@property (strong, nonatomic) UISS *uiss;

@end

@implementation WatchedAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.uiss = [UISS configureWithDefaultJSONFile];
    //self.uiss.statusWindowEnabled = YES;
    
    [MJInternetConnection sharedInternetConnection];
    [UIResponder cacheKeyboard:YES];
    
    [Crashlytics startWithAPIKey:@"145e624fa03124a3e4abe820c9bf1a8a9fe96274"];
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
    [TestFlight setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"logToConsole"]];
    [TestFlight setOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"logToSTDERR"]];
    NSString *token = @"b4bbe6c9-dd95-4a5b-98b9-1c24baf90bae";
#ifdef DEBUG_MODE
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [TestFlight takeOff:token];
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
    
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    AFJSONRequestOperation *operation = [bridge saveMovieForID:[NSNumber numberWithInt:serverID] completion:^(Movie *movie) {
        
    } failure:^(NSError *error) {
        DebugLog("%@", [error localizedDescription]);
    }];
    [operation start];
    
    return YES;
}

@end

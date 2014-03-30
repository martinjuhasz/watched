//
//  MJUWatchedStyle.m
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import "MJUWatchedStyle.h"

@implementation MJUWatchedStyle

+ (void)setupDefaultStyle
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BgNavigationBar"] forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:240.0f green:0.0f blue:0.0f alpha:1.0f]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AvenirNext-DemiBold" size:17.0f],
      NSFontAttributeName,
      nil]];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:15.0f]];
}

@end

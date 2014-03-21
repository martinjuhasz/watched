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
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationbar_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:240.0f green:0.0f blue:0.0f alpha:1.0f]];
}

@end

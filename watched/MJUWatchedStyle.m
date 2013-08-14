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
}

@end

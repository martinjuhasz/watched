//
//  MJWatchedNavigationController.m
//  watched
//
//  Created by Martin Juhasz on 17.09.12.
//
//

#import "MJWatchedNavigationController.h"

@interface MJWatchedNavigationController ()

@end

@implementation MJWatchedNavigationController

- (BOOL)shouldAutorotate
{
    if(_shouldRotate) return YES;
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if(_shouldRotate) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
    
}

@end

//
//  MJInternetConnection.m
//  watched
//
//  Created by Martin Juhasz on 03.09.12.
//
//

#import "MJInternetConnection.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "KSReachability.h"
#import "BlockAlertView.h"

@interface MJInternetConnection () {
    KSReachability *_reachability;
}
@end

@implementation MJInternetConnection



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initializing

- (id)init {
    self = [super init];
    if (self) {
        _internetAvailable = NO;
        __weak __block MJInternetConnection *blockSelf = self;
        _reachability = [KSReachability reachabilityToHost:@"http://google.de/"];
        _reachability.onReachabilityChanged = ^(KSReachability* reachability)
        {
            blockSelf.internetAvailable = (reachability.reachable) ? YES : NO;
        };
    }
    return self;
}

+ (id)sharedInternetConnection
{
    static MJInternetConnection *__instance = nil;
    if (__instance == nil) {
        __instance = [[MJInternetConnection alloc] init];
    }
    
    return __instance;
}

- (void)displayAlert
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"ALERT_NOINTERNET_TITLE", nil)
                                                   message:NSLocalizedString(@"ALERT_NOINTERNET_TITLE_CONTENT", nil)];
    [alert setCancelButtonWithTitle:NSLocalizedString(@"ALERT_NOINTERNET_TITLE_OK", nil) block:nil];
    [alert show];
}



@end

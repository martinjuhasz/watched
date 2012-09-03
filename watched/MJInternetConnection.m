//
//  MJInternetConnection.m
//  watched
//
//  Created by Martin Juhasz on 03.09.12.
//
//

#import "MJInternetConnection.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "AFHTTPClient.h"
#import "BlockAlertView.h"

@interface MJInternetConnection () {
    AFHTTPClient *_client;
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
        __weak MJInternetConnection *blockSelf = self;
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://google.de/"]];
        [_client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
                blockSelf.internetAvailable = YES;
            } else {
                blockSelf.internetAvailable = NO;
            }
        }];
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

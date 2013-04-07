//
//  WatchedWebBrowser.h
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrowserBarButtonItem;
@class MJWatchedNavigationController;

@interface WatchedWebBrowser : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) BrowserBarButtonItem *reloadButton;
@property (strong, nonatomic) BrowserBarButtonItem *forwardButton;
@property (strong, nonatomic) BrowserBarButtonItem *backButton;
@property (strong, nonatomic) BrowserBarButtonItem *actionButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (assign, nonatomic) MJWatchedNavigationController *navController;

@property (strong, nonatomic) NSURL *url;

- (id)initWithURL:(NSURL*)aUrl;

@end

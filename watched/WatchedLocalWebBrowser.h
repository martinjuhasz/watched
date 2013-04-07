//
//  WatchedLocalWebBrowser.h
//  watched
//
//  Created by Martin Juhasz on 13.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchedLocalWebBrowser : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;

- (id)initWithURL:(NSURL*)aUrl;

@end

//
//  WatchedLocalWebBrowser.m
//  watched
//
//  Created by Martin Juhasz on 13.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WatchedLocalWebBrowser.h"

@interface WatchedLocalWebBrowser ()

@end

@implementation WatchedLocalWebBrowser
@synthesize webView;
@synthesize url;

- (id)initWithURL:(NSURL*)aUrl
{
    self = [super init];
    if (self) {
        self.url = aUrl;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

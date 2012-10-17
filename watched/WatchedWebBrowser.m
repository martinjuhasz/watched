//
//  WatchedWebBrowser.m
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WatchedWebBrowser.h"
#import <MessageUI/MessageUI.h>
#import "BrowserBarButtonItem.h"
#import "BlockActionSheet.h"
#import "MJInternetConnection.h"
#import "MJWatchedNavigationController.h"

#define kButtonViewTag 500

@interface WatchedWebBrowser () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation WatchedWebBrowser



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    
    // check for webz
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
    }
    
    // Enable Rotation
    _navController = (MJWatchedNavigationController*)self.navigationController;
//    _navController.shouldRotate = YES;
    
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    self.reloadButton = [BrowserBarButtonItem browserItemWithImageName:@"g_browser_reload.png" disabledImageName:nil];
    [self.reloadButton.button addTarget:self action:@selector(reloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.forwardButton = [BrowserBarButtonItem browserItemWithImageName:@"g_browser_forward.png" disabledImageName:nil];
    [self.forwardButton.button addTarget:self action:@selector(forwardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = [BrowserBarButtonItem browserItemWithImageName:@"g_browser_back.png" disabledImageName:nil];
    [self.backButton.button addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.actionButton = [BrowserBarButtonItem browserItemWithImageName:@"g_browser_action.png" disabledImageName:nil];
    [self.actionButton.button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = 35.0f;
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.toolbar.items = [NSArray arrayWithObjects:self.backButton,fixed,self.forwardButton,fixed,self.reloadButton,flexible,self.actionButton, nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                   UITextAttributeFont,
                                                                   nil];
}

- (void)dealloc
{
    [self.webView setDelegate:nil];
//    _navController.shouldRotate = NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f],
                                                                       UITextAttributeFont, 
                                                                       nil];
    } else {
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f],
                                                                       UITextAttributeFont,
                                                                       nil];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    // work-around for navigation bar appearing under status bar - must be called before -setNavigationBarHidden:
    self.view.window.rootViewController.view.frame = [UIScreen mainScreen].applicationFrame;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
    [self setButtonStates];
    
    // set title
    NSString *newTitle = @"";
    if(![self.webView.request.URL absoluteString] || [[self.webView.request.URL absoluteString] isEqualToString:@""]) {
        newTitle = [self.url absoluteString];
    } else {
        newTitle = [self.webView.request.URL absoluteString];
    }
    self.title = newTitle;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    [self setButtonStates];
    
    // get new title
    NSString *newTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if(newTitle) self.title = newTitle;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    [self setButtonStates];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Handling

- (void)setButtonStates
{
    if(self.webView.isLoading) {
        self.backButton.enabled = NO;
        self.forwardButton.enabled = NO;
        
        UIImage *buttonImage = [UIImage imageNamed:@"g_browser_stop.png"];
        [self.reloadButton.button setImage:buttonImage forState:UIControlStateNormal];
        
    } else if (!self.webView.isLoading) {
        if(self.webView.canGoBack) self.backButton.enabled = YES;
        if(self.webView.canGoForward) self.forwardButton.enabled = YES;
        
        UIImage *buttonImage = [UIImage imageNamed:@"g_browser_reload.png"];
        [self.reloadButton.button setImage:buttonImage forState:UIControlStateNormal];
        
        
    }
    if(!self.webView.request.URL || [[self.webView.request.URL absoluteString] isEqualToString:@""]) {
        self.actionButton.enabled = NO;
    } else {
        self.actionButton.enabled = YES;
    }
}

- (IBAction)backButtonClicked:(id)sender
{
    if(!self.webView.canGoBack) return;
    [self.webView goBack];
}

- (IBAction)forwardButtonClicked:(id)sender
{
    if(!self.webView.canGoForward) return;
    [self.webView goForward];
}

- (IBAction)reloadButtonClicked:(id)sender
{
    if(self.webView.isLoading) {
        [self.webView stopLoading];
    } else {
        [self.webView reload];
    }
}

- (IBAction)actionButtonClicked:(id)sender
{
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:[self.webView.request.URL absoluteString]];
    
    // E-Mail
    if([MFMailComposeViewController canSendMail]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil) block:^{
            [self shareWithEmail];
        }];
    }

    // Open in Safari
    [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_OPENSAFARI",nil) block:^{
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }];
    
    // Copy URL
    [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_COPYURL",nil) block:^{
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = [self.webView.request.URL absoluteString];
    }];
    
    // Cancel Button
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_CANCEL",nil) block:nil];
    
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (UIBarButtonItem*)buttonItemForToolbarWithImageName:(NSString*)imageName target:(SEL)target
{
    // Initialize the UIButton
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    aButton.showsTouchWhenHighlighted = YES;
    aButton.tag = kButtonViewTag;
    
    // Initialize the UIBarButtonItem
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
    // Set the Target and Action for aButton
    [aButton addTarget:self action:target forControlEvents:UIControlEventTouchUpInside];
    return aBarButtonItem;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Sharing

- (void)shareWithEmail
{
    // check if can send mail
    if(![MFMailComposeViewController canSendMail]) return;
    
    // Title and URL
    NSString *mailTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *mailContent = [self.webView.request.URL absoluteString];
    
    // Generate Mail Composer and View it
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:mailTitle];
    [mailViewController setMessageBody:mailContent isHTML:NO];
    
    [self presentModalViewController:mailViewController animated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}



@end





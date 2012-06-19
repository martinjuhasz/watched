//
//  WatchedWebBrowser.m
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WatchedWebBrowser.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>
#import "Reachability.h"

@interface WatchedWebBrowser () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    Reachability *reachability;
}
@end

@implementation WatchedWebBrowser

@synthesize webView;
@synthesize activityIndicator;
@synthesize reloadButton;
@synthesize forwardButton;
@synthesize backButton;
@synthesize actionButton;

@synthesize url;



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
    
    self.webView.delegate = self;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setWebView:nil];
    [self setReloadButton:nil];
    [self setForwardButton:nil];
    [self setBackButton:nil];
    [self setActionButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // check reachability
    reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.unreachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_NOINTERNET_TITLE", nil)
                                                            message:NSLocalizedString(@"ALERT_NOINTERNET_TITLE_CONTENT", nil)
                                                           delegate:nil 
                                                  cancelButtonTitle:NSLocalizedString(@"ALERT_NOINTERNET_TITLE_OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        });
    };
    [reachability startNotifier];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [reachability stopNotifier];
    reachability = nil;
}

- (void)dealloc
{
    [self.webView setDelegate:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    XLog("");
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        self.reloadButton.title = @"st"; 
    } else if (!self.webView.isLoading) {
        if(self.webView.canGoBack) self.backButton.enabled = YES;
        if(self.webView.canGoForward) self.forwardButton.enabled = YES;
        self.reloadButton.title = @"re";
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
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] init];
    shareActionSheet.delegate = self;
    shareActionSheet.title = [self.webView.request.URL absoluteString];
    
    // E-Mail
    if([MFMailComposeViewController canSendMail])
        [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil)];
    
    // Twitter
    [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_TWITTER",nil)];
    
    // Open in Safari
    [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_OPENSAFARI",nil)];
    
    // Copy URL
    [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_COPYURL",nil)];
    
    // Cancel Button
    [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_CANCEL",nil)];
    [shareActionSheet setCancelButtonIndex:[shareActionSheet numberOfButtons]-1];
    
    [shareActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil)]) {
        [self shareWithEmail];
    } else if([title isEqualToString:NSLocalizedString(@"SHARE_BUTTON_TWITTER",nil)]) {
        [self shareWithTwitter];
    } else if ([title isEqualToString:NSLocalizedString(@"SHARE_BUTTON_OPENSAFARI",nil)]) {
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    } else if ([title isEqualToString:NSLocalizedString(@"SHARE_BUTTON_COPYURL",nil)]) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = [self.webView.request.URL absoluteString];
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Sharing

- (void)shareWithTwitter
{
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    [twitter addURL:self.webView.request.URL];
    
    [self presentModalViewController:twitter animated:YES];
}

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





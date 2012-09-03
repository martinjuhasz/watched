//
//  AddMovieViewController.m
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddMovieViewController.h"
#import "SearchResult.h"
#import "OnlineMovieDatabase.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+MJPopupViewController.h"
#import "NSDictionary+ObjectForKeyOrNil.h"
#import "OnlineDatabaseBridge.h"
#import "MoviesDataModel.h"
#import "Movie.h"
#import "AFJSONRequestOperation.h"
#import "UIButton+Additions.h"
#import "MJInternetConnection.h"


@interface AddMovieViewController () <MJPopupViewControllerDelegate> {
    NSDictionary *resultDict;
    BOOL appeard;
    BOOL isAdding;
}

@end

@implementation AddMovieViewController

@synthesize retryButton;
@synthesize errorLabel;
@synthesize navBar;
@synthesize backgroundImageView;
@synthesize loadingView;
@synthesize displayView;
@synthesize infoView;
@synthesize infoLabel;
@synthesize imageView;
@synthesize scrollView;
@synthesize overviewLabel;
@synthesize saveButton;
@synthesize cancelButton;
@synthesize searchResult;
@synthesize coverImage;
@synthesize delegate;
@synthesize resultID;
@synthesize movie;

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Appearance
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *popoverBgImage = [[UIImage imageNamed:@"pv_bg_content.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 17.0f, 15.0f, 17.0f)];
    self.backgroundImageView.image = popoverBgImage;
    self.loadingView.backgroundColor = HEXColor(0xd9d9d9);
    self.displayView.backgroundColor = [UIColor clearColor];
    self.infoView.backgroundColor = HEXColor(0xd9d9d9);
    
    // Cancel Button
    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(2.0f, 1.0f, 55.0f, 30.0f)];
    [self.cancelButton setTitle:NSLocalizedString(@"POPUP_DONEBUTTON", nil)];
    
    // cancel button styles
    UIImage *barButtonBgImage = [[UIImage imageNamed:@"g_barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    UIImage *barButtonBgImageActive = [[UIImage imageNamed:@"g_barbutton_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    [self.cancelButton setBackgroundImage:barButtonBgImage];
    [self.cancelButton setBackgroundImage:barButtonBgImageActive forState:UIControlStateHighlighted];
    self.cancelButton.titleLabel.textColor = HEXColor(0xFFFFFF);
    self.cancelButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
    self.cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    
    // adding cancel button
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelView addSubview:self.cancelButton];
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithCustomView:cancelView];
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.rightBarButtonItem = cancelBarItem;
    item.hidesBackButton = YES;
    [self.navBar pushNavigationItem:item animated:NO];
    
    UIImage *addBtnImage = [[UIImage imageNamed:@"g_button_popover_add.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    UIImage *addBtnImageDis = [[UIImage imageNamed:@"g_button_popover_add_disabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    UIImage *addBtnImageHigh = [[UIImage imageNamed:@"g_button_popover_add_highlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    [self.saveButton setBackgroundImage:addBtnImage];
    [self.saveButton setBackgroundImage:addBtnImageDis forState:UIControlStateDisabled];
    [self.saveButton setBackgroundImage:addBtnImageHigh forState:UIControlStateHighlighted];
    
    UIImage *retryBtnImage = [[UIImage imageNamed:@"pv_error-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    UIImage *retryBtnImageActive = [[UIImage imageNamed:@"pv_error-button-selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    [self.retryButton setBackgroundImage:retryBtnImage];
    [self.retryButton setBackgroundImage:retryBtnImageActive forState:UIControlStateHighlighted];
    [self.retryButton setTitle:NSLocalizedString(@"POPUP_TMDBERROR-BUTTON", nil)];
    
    // other
    appeard = NO;
    isAdding = NO;
    
    if(self.searchResult) {
        self.resultID = self.searchResult.searchResultId;
    }
    
    self.movie = [Movie movieWithServerId:[self.resultID intValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]]; 
    
    if(self.movie) {
        [self loadContentWithExistingMovie];
    } else if (self.searchResult) {
        [self loadContentWithExistingSearchResult];
    } else if (self.resultID) {
        [self loadContentWithExistingResultID];
    }
    
}

- (void)viewDidUnload
{
    [self setNavBar:nil];
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setOverviewLabel:nil];
    [self setSaveButton:nil];
    [self setLoadingView:nil];
    [self setDisplayView:nil];
    [self setInfoView:nil];
    [self setInfoLabel:nil];
    [self setBackgroundImageView:nil];
    [self setBackgroundImageView:nil];
    [self setRetryButton:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (IBAction)cancelButtonClicked:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(AddMovieControllerCancelButtonClicked:)]) {
        [self.delegate AddMovieControllerCancelButtonClicked:self];
    }
}

- (IBAction)saveButtonClicked:(id)sender
{
    if(!resultDict) return;
    
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
        return;
    }
    
    [self saveMovieToDatabase];
}

- (IBAction)retryButtonClicked:(id)sender
{
    if (self.searchResult) {
        [self loadContentWithExistingSearchResult];
    } else if (self.resultID) {
        [self loadContentWithExistingResultID];
    } else {
        return;
    }
    [self showLoading];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content

- (void)loadContentWithExistingSearchResult
{
    self.navBar.topItem.title = self.searchResult.title;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:self.searchResult.posterPath imageType:ImageTypePoster nearWidth:80.0f*2];
    [self.imageView setImageWithURL:imageURL];
    if(self.coverImage) self.imageView.image = self.coverImage;
    [self loadContent];
}

- (void)loadContentWithExistingResultID
{
    self.navBar.topItem.title = NSLocalizedString(@"POPUP_TITLE_LOADING", nil);
    [self loadContent];
}

- (void)loadContentWithExistingMovie
{
    self.imageView.image = self.movie.poster;
    self.navBar.topItem.title = self.movie.title;
    [self setOverviewContent:self.movie.overview];
    [self checkButtonStates];
    [self showContent];
}

- (void)loadContent
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:self.resultID completion:^(NSDictionary *aResultDict) {
        resultDict = aResultDict;
        
        [self setOverviewContent:[resultDict objectForKeyOrNil:@"overview"]];
        self.navBar.topItem.title = [resultDict objectForKeyOrNil:@"title"];
        
        if(!self.imageView.image) {
            NSString *imagePath = [resultDict objectForKeyOrNil:@"poster_path"];
            NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:imagePath 
                                                                                       imageType:ImageTypePoster 
                                                                                       nearWidth:80.0f*2];
            [self.imageView setImageWithURL:imageURL];
        }
        
        [self checkButtonStates];
        [self showContent];
        
    } failure:^(NSError *error) {
        XLog(@"%@", [error localizedDescription]);
        self.retryButton.alpha = 1.0f;
        [self showInfoContentWithText:NSLocalizedString(@"POPUP_TMDBERROR-LOAD", nil) titleText:NSLocalizedString(@"POPUP_TMDBERROR-INFO", nil)];
    }];
    [operation start];
}

- (void)checkButtonStates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.cancelButton.enabled = YES;
        
        if(self.movie) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDED", nil)];
            self.saveButton.enabled = NO;
            return;
        }
        
        if(isAdding) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDING", nil)];
            self.saveButton.enabled = NO;
            self.cancelButton.enabled = NO;
            return;
        }

        if(resultDict && [resultDict count] > 0) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil)];
            self.saveButton.enabled = YES;
            return;
        }

        if(!resultDict || [resultDict count] <= 0) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil)];
            self.saveButton.enabled = NO;
        }
    });
   
    
}

- (void)setOverviewContent:(NSString*)content
{
    self.overviewLabel.text = content;
    [self.overviewLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
    
    [self.overviewLabel sizeToFit];
    
    CGSize scrollviewContentSize = self.scrollView.frame.size;
    scrollviewContentSize.height = self.overviewLabel.frame.size.height;
    self.scrollView.contentSize = scrollviewContentSize;
}

- (void)showContent
{
    [self.displayView setAlpha:1.0f];
    [self.infoView setAlpha:0.0f];
    [self.loadingView setAlpha:0.0f];
}

- (void)hideContent
{
    [self.loadingView setAlpha:1.0f];
    [self.infoView setAlpha:0.0f];
    [self.displayView setAlpha:0.0f];
}

- (void)showLoading
{
    [self.loadingView setAlpha:1.0f];
    [self.displayView setAlpha:0.0f];
    [self.infoView setAlpha:0.0f];
}

- (void)showInfoContentWithText:(NSString*)aText titleText:(NSString*)titleText
{
    self.infoLabel.text = titleText;
    self.errorLabel.text = aText;
    [self.view bringSubviewToFront:self.infoView];
    [UIView animateWithDuration:0.3f animations:^{
        [self.infoView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        [self.loadingView setAlpha:0.0f];
        [self.displayView setAlpha:0.0f];
    }];
}

- (void)hideInfoContent
{
    [self.displayView setAlpha:1.0f];
    [self checkButtonStates];
    [UIView animateWithDuration:0.3f animations:^{
        [self.infoView setAlpha:0.0f];
    }];
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase
{
    if(!appeard || !resultDict || [resultDict count] <= 0) return;
    isAdding = YES;
    [self checkButtonStates];
    
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    [bridge saveSearchResultDictAsMovie:resultDict completion:^(Movie *aMovie) {
        isAdding = NO;
        self.movie = aMovie;
        [self checkButtonStates];
        
        // show info and close window
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SUCCESS_ADDED", nil)];
            [self performSelector:@selector(cancelButtonClicked:) withObject:self afterDelay:2.0f];
        });
        
    } failure:^(NSError *error) {
        XLog(@"%@", [error localizedDescription]);
        isAdding = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.retryButton.alpha = 0.0f;
            [self showInfoContentWithText:NSLocalizedString(@"POPUP_TMDBERROR-TRY", nil) titleText:NSLocalizedString(@"POPUP_TMDBERROR-INFO", nil)];
            [self performSelector:@selector(hideInfoContent) withObject:self afterDelay:3.0f];
        });
    }];
    
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MJPopupViewControllerDelegate

- (void)MJPopViewControllerDidAppearCompletely
{
    appeard = YES;    
}



@end

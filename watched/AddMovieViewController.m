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
#import "Reachability.h"

@interface AddMovieViewController () <MJPopupViewControllerDelegate> {
    Reachability *reachability;
    NSDictionary *resultDict;
    BOOL appeard;
    BOOL isAdding;
}

@end

@implementation AddMovieViewController

@synthesize navBar;
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
    [self setCancelButton:nil];
    [self setLoadingView:nil];
    [self setDisplayView:nil];
    [self setInfoView:nil];
    [self setInfoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // check reachability
    reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    reachability.unreachableBlock = ^(Reachability*reach)
    {
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
    [reachability stopNotifier];
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (IBAction)cancelButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AddMovieControllerCancelButtonClicked:)]) {
        [self.delegate AddMovieControllerCancelButtonClicked:self];
    }
}

- (IBAction)saveButtonClicked:(id)sender
{
    if(!resultDict) return;
    XLog("");
    [self saveMovieToDatabase];
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
    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:self.resultID completion:^(NSDictionary *aResultDict) {
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
        [self showInfoContentWithText:NSLocalizedString(@"POPUP_FAILED", nil)];
    }];
}

- (void)checkButtonStates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.movie) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDED", nil) forState:UIControlStateNormal];
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDED", nil) forState:UIControlStateDisabled];
            self.saveButton.enabled = NO;
            return;
        }
        
        if(isAdding) {
            self.saveButton.enabled = NO;
            return;
        }

        if(resultDict && [resultDict count] > 0) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateNormal];
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateDisabled];
            self.saveButton.enabled = YES;
            return;
        }

        if(!resultDict || [resultDict count] <= 0) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateNormal];
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateDisabled];
            self.saveButton.enabled = NO;
        }
    });
   
    
}

- (void)setOverviewContent:(NSString*)content
{
    self.overviewLabel.text = content;
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

- (void)showInfoContentWithText:(NSString*)aText
{
    self.infoLabel.text = aText;
    [self.infoView setAlpha:1.0f];
    [self.loadingView setAlpha:0.0f];
    [self.displayView setAlpha:0.0f];
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
    } failure:^(NSError *error) {
        XLog(@"%@", [error localizedDescription]);
        isAdding = NO;
        [self checkButtonStates];
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

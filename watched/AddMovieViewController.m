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

@interface AddMovieViewController () <MJPopupViewControllerDelegate> {
    NSDictionary *resultDict;
    BOOL appeard;
    BOOL isAdding;
}

@end

@implementation AddMovieViewController

@synthesize navBar;
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
    if(!self.resultID) return;
    
    self.movie = [Movie movieWithServerId:[self.resultID intValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]]; 
    
    if(self.movie) {
        [self loadContentWithExistingMovie];
    } else if (self.searchResult) {
        [self loadContentWithExistingSearchResult];
    } else if (self.resultID) {
        [self loadContentWithExistingResultID];
    }
    
//    self.navBar.topItem.title = self.searchResult.title;
//    [self checkButtonStates];
//    
//    // Image
//    if(self.coverImage) self.imageView.image = self.coverImage;
//    if(self.searchResult) {
//        NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:self.searchResult.posterPath imageType:ImageTypePoster nearWidth:80.0f*2];
//        [self.imageView setImageWithURL:imageURL];
//    }
//    // Details
//    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:self.resultID completion:^(NSDictionary *aResultDict) {
//        resultDict = aResultDict;
//        [self checkButtonStates];  
//        [self setContent];
//    } failure:^(NSError *error) {
//        XLog(@"%@", [error localizedDescription]);
//        [self checkButtonStates];
//        [self cancelButtonClicked:nil];
//    }];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setNavBar:nil];
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setOverviewLabel:nil];
    [self setSaveButton:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [self checkButtonStates];
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
    [self checkButtonStates];
}

- (void)loadContentWithExistingResultID
{
    self.navBar.topItem.title = NSLocalizedString(@"POPUP_TITLE_LOADING", nil);
    [self loadContent];
    [self checkButtonStates];
}

- (void)loadContentWithExistingMovie
{
    self.imageView.image = self.movie.poster;
    self.navBar.topItem.title = self.movie.title;
    [self setOverviewContent:self.movie.overview];
    [self checkButtonStates];
}

- (void)loadContent
{
    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:self.resultID completion:^(NSDictionary *aResultDict) {
        resultDict = aResultDict;
        [self checkButtonStates];
        
        [self setOverviewContent:[resultDict objectForKeyOrNil:@"overview"]];
        self.navBar.topItem.title = [resultDict objectForKeyOrNil:@"title"];
        NSString *imagePath = [resultDict objectForKeyOrNil:@"poster_path"];
        NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:imagePath imageType:ImageTypePoster nearWidth:80.0f*2];
        [self.imageView setImageWithURL:imageURL];
        
        
    } failure:^(NSError *error) {
        XLog(@"%@", [error localizedDescription]);
        [self checkButtonStates];
        [self cancelButtonClicked:nil];
    }];
}

- (void)checkButtonStates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.movie) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDED", nil) forState:UIControlStateNormal];
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDED", nil) forState:UIControlStateDisabled];
            self.saveButton.enabled = NO;
            self.cancelButton.enabled = YES;
            return;
        }

        if(!appeard) {
            self.saveButton.enabled = NO;
            self.cancelButton.enabled = NO;
            return;
        }
        
        if(isAdding) {
            self.saveButton.enabled = NO;
            self.cancelButton.enabled = YES;
            return;
        }

        if(resultDict && [resultDict count] > 0) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateNormal];
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateDisabled];
            self.saveButton.enabled = YES;
            self.cancelButton.enabled = YES;
            return;
        }

        if(!resultDict || [resultDict count] <= 0) {
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateNormal];
            [self.saveButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil) forState:UIControlStateDisabled];
            self.saveButton.enabled = NO;
            self.cancelButton.enabled = YES;
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



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase
{
    if(!appeard || !resultDict || [resultDict count] <= 0) return;
    isAdding = YES;
    
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
    [self checkButtonStates];
}



@end

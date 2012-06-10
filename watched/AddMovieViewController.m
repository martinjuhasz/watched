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

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appeard = NO;
    
    if(!self.searchResult) return;
    
    self.navBar.topItem.title = self.searchResult.title;
    [self checkButtonStates];
    
    // Image
    if(self.coverImage) self.imageView.image = self.coverImage;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:self.searchResult.posterPath imageType:ImageTypePoster nearWidth:80.0f*2];
    [self.imageView setImageWithURL:imageURL];
    
    // Details
    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:self.searchResult.searchResultId completion:^(NSDictionary *aResultDict) {
        resultDict = aResultDict;
        [self checkButtonStates];  
        [self setContent];
    } failure:^(NSError *error) {
        XLog(@"%@", [error localizedDescription]);
        [self checkButtonStates];
        [self cancelButtonClicked:nil];
    }];
    
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

- (void)setContent
{
    self.overviewLabel.text = [resultDict objectForKeyOrNil:@"overview"];
    [self.overviewLabel sizeToFit];
    CGSize scrollviewContentSize = self.scrollView.frame.size;
    scrollviewContentSize.height = self.overviewLabel.frame.size.height;
    self.scrollView.contentSize = scrollviewContentSize;
}

- (void)checkButtonStates
{
    Movie *mov = [Movie movieWithServerId:[self.searchResult.searchResultId intValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(mov) {
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



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase
{
    if(!appeard || !resultDict || [resultDict count] <= 0) return;
    
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    [bridge saveSearchResultDictAsMovie:resultDict completion:^(Movie *aMovie) {
        [self checkButtonStates];
    } failure:^(NSError *error) {
        XLog(@"%@", [error localizedDescription]);
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

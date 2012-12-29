//
//  MoviePopupViewController.m
//  watched
//
//  Created by Martin Juhasz on 17.10.12.
//
//

#import "MoviePopupViewController.h"
#import "MoviePopupView.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import "Movie.h"
#import "MoviesDataModel.h"
#import "OnlineMovieDatabase.h"
#import "UILabel+Additions.h"
#import "AFJSONRequestOperation.h"
#import "NSDictionary+ObjectForKeyOrNil.h"
#import "OnlineDatabaseBridge.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Additions.h"
#import "UIViewController+MJPopupViewController.h"
#import "MJInternetConnection.h"
#import "UIButton+Additions.h"

@interface MoviePopupViewController ()<MJPopupViewControllerDelegate> {
    NSDictionary *resultDict;
    BOOL isAdding;
}

@end

@implementation MoviePopupViewController

- (void)loadView
{
    CGRect startingPopupSize = CGRectMake(0.0f, 0.0f, 300.0f, 160.0f);
    _popupView = [[MoviePopupView alloc] initWithFrame:startingPopupSize];
    self.view = _popupView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_popupView.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_popupView.addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    isAdding = NO;
    
    if(self.searchResult) {
        self.resultID = self.searchResult.searchResultId;
    }
    
    self.movie = [Movie movieWithServerId:[self.resultID intValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
    
    if(self.movie) {
        [self loadContentWithExistingMovie];
    } else if (self.searchResult || self.resultID) {
        [self loadContent];
    }
}

-(IBAction)cancelButtonClicked:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(moviePopupCancelButtonClicked:)]) {
        [self.delegate moviePopupCancelButtonClicked:self];
    }
}

- (IBAction)addButtonClicked:(id)sender
{
    if(_popupView.displayState == PopupViewDisplayStateContent) {
        [self saveButtonClicked:nil];
    } else if(_popupView.displayState == PopupViewDisplayStateError) {
        [self retryButtonClicked:nil];
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
    [_popupView addAnimation:PopupViewDisplayStateLoading animated:NO];
    if (self.searchResult || self.resultID) {
        [self loadContent];
    } else {
        return;
    }
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content

- (void)loadContentWithExistingMovie
{
    _popupView.coverImageView.image = self.movie.poster;
    _popupView.navBar.topItem.title = self.movie.title;
    _popupView.titleLabel.text = self.movie.title;
    [_popupView.titleLabel sizeToFitWithWith:190.0f andMaximumNumberOfLines:3];
    [self setYearLabelWithDate:self.movie.releaseDate];
    
    [_popupView setOverviewContent:self.movie.overview];
    [self checkButtonStates];
    _popupView.displayState = PopupViewDisplayStateContent;
}

- (void)loadContent
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:self.resultID completion:^(NSDictionary *aResultDict) {
        resultDict = aResultDict;
        
        [_popupView setOverviewContent:[resultDict objectForKeyOrNil:@"overview"]];
        _popupView.navBar.topItem.title = [resultDict objectForKeyOrNil:@"title"];
        _popupView.titleLabel.text = [resultDict objectForKeyOrNil:@"title"];
        [_popupView.titleLabel sizeToFitWithWith:190.0f andMaximumNumberOfLines:3];
        
        if([resultDict objectForKeyOrNil:@"release_date"]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-DD"];
            NSDate *releaseDate = [dateFormatter dateFromString:[resultDict objectForKeyOrNil:@"release_date"]];
            [self setYearLabelWithDate:releaseDate];
        }
        
//        if(!_popupView.coverImageView.image) {
            NSString *imagePath = [resultDict objectForKeyOrNil:@"poster_path"];
            NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:imagePath
                                                                                       imageType:ImageTypePoster
                                                                                       nearWidth:80.0f*2];
            [_popupView.coverImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"dv_placeholder-cover.png"]];
//        }
        
        [self checkButtonStates];
        _popupView.displayState = PopupViewDisplayStateContent;
        
    } failure:^(NSError *error) {
        DebugLog(@"%@", [error localizedDescription]);
        _popupView.displayState = PopupViewDisplayStateError;
    }];
    [operation start];
}

- (void)setYearLabelWithDate:(NSDate*)aDate
{
    // get year
    if(aDate) {
        NSUInteger componentFlags = NSYearCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:aDate];
        NSInteger year = [components year];
        CGRect yearLabelRect = _popupView.yearLabel.frame;
        yearLabelRect.origin.y = _popupView.titleLabel.bottom;
        _popupView.yearLabel.frame = yearLabelRect;
        _popupView.yearLabel.text = [NSString stringWithFormat:@"%d", year];
    } else {
        _popupView.yearLabel.text = @"";
    }
}

- (void)checkButtonStates
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _popupView.cancelButton.enabled = YES;
        UIButton *addButton = _popupView.addButton;
        
        if (_popupView.displayState == PopupViewDisplayStateContent) {
            
            if(self.movie) {
                [addButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDED", nil)];
                addButton.enabled = NO;
                return;
            }
            
            if(isAdding) {
                [addButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADDING", nil)];
                addButton.enabled = NO;
                _popupView.cancelButton.enabled = NO;
                return;
            }
            
            if(resultDict && [resultDict count] > 0) {
                [addButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil)];
                addButton.enabled = YES;
                return;
            }
            
            if(!resultDict || [resultDict count] <= 0) {
                [addButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil)];
                addButton.enabled = NO;
            }
        
        } else if(_popupView.displayState == PopupViewDisplayStateLoading) {
        
            [addButton setTitle:NSLocalizedString(@"POPUP_TMDBERROR-BUTTON", nil)];
            addButton.enabled = YES;
            
        }
    });
    
    
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase
{
    
    //
    if(!_appeard || !resultDict || [resultDict count] <= 0) return;
    isAdding = YES;
    [self checkButtonStates];
    
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    [bridge saveSearchResultDictAsMovie:resultDict completion:^(Movie *aMovie) {
        isAdding = NO;
        self.movie = aMovie;
        
        // show info and close window
        dispatch_async(dispatch_get_main_queue(), ^{
            [_popupView.addButton setTitle:NSLocalizedString(@"POPUP_SUCCESS_ADDED", nil)];
            [self performSelector:@selector(cancelButtonClicked:) withObject:self afterDelay:0.75f];
        });
        
    } failure:^(NSError *error) {
        DebugLog(@"%@", [error localizedDescription]);
        isAdding = NO;
        [self checkButtonStates];
        dispatch_async(dispatch_get_main_queue(), ^{
            _popupView.displayState = PopupViewDisplayStateError;
        });
    }];
    
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MJPopupViewControllerDelegate

- (void)MJPopViewControllerDidAppearCompletely
{
    _appeard = YES;
    [_popupView viewAppeardCompletely];
}

@end

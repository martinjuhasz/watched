//
//  SearchMovieViewController.m
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "SearchMovieViewController.h"
#import "OnlineMovieDatabase.h"
#import "SearchResult.h"
#import "UIImageView+AFNetworking.h"
#import "UISearchBar+Additions.h"
#import "OnlineDatabaseBridge.h"
#import "Movie.h"
#import "UIViewController+MJPopupViewController.h"
#import "AFJSONRequestOperation.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "MoviesDataModel.h"
#import "MJInternetConnection.h"
#import "MoviePopupViewController.h"

#define kSearchMovieLoadingTableViewCell @"SearchMovieLoadingTableViewCell"
#define kSearchMovieTableViewCell @"SearchMovieTableViewCell"

@interface SearchMovieViewController ()<MoviePopupViewControllerDelegate>
@end


@implementation SearchMovieViewController

@synthesize navigationBar;
@synthesize searchQuery;
@synthesize movieID;
@synthesize tableView;
@synthesize searchBar;
@synthesize searchResults;

const int kMovieSearchLoadingCellTag = 2000;
const int kMovieSearchInfoCellTag = 2001;
const int kMovieSearchCellTitleLabel = 100;
const int kMovieSearchCellYearLabel = 101;
const int kMovieSearchCellImageView = 200;
const int kMetaTitleLabelTag = 34772;
const int kMovieFlagCellTag = 34773;


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar setCancelButtonActive];
    [self.searchBar becomeFirstResponder];
    
    if(self.movieID) {
        navigationBar.topItem.title = NSLocalizedString(@"BUTTON_SIMILAR", nil);
    }
    
    
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectZero];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = emptyTable;
    
    
    currentPage = 0;
    isError = NO;
    
    if((self.searchQuery && ![self.searchQuery isEqualToString:@""]) || (self.movieID && [self.movieID intValue] > 0)) {
        isLoading = YES;
    } else {
        isLoading = NO;
    }
    self.searchResults = [NSMutableArray array];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [self setTableView:nil];
    [self setSearchBar:nil];
    [self setNavigationBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//- (void)dealloc
//{
//    if (self.addController) {
//        self.addController.delegate = nil;
//    }
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    if (self.addController) {
//        self.addController.delegate = nil;
//    }
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // should be empty
    if((!self.searchQuery || [self.searchQuery isEqualToString:@""]) && (!self.movieID || [self.movieID intValue] <= 0)) return 0;
    
    // first search
    if(isLoading) return 1;
    
    // no result
    if(!isLoading && self.searchResults.count == 0) return 1;
    
    // display extra loading cell if there are some results
    if(self.searchResults.count > 0 && totalPages > currentPage) {
        return self.searchResults.count + 1;
    }
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    // check to see if loading cell needs to be displayed
    if (indexPath.row < self.searchResults.count) {
        cell = [self resultCellAtIndexPath:indexPath];
    } else if (!isLoading && self.searchResults.count == 0 && !isError) {
        cell = [self infoCell];
    }  else if (!isLoading && self.searchResults.count == 0 && isError) {
        cell = [self errorCell];
    } else {
        cell = [self loadingCell];
    }
    
    // appearance
    UIView *tableCellBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 79.0f)];
    tableCellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table.png"]];
    UIView *tableCellBackgroundViewSelected = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 79.0f)];
    tableCellBackgroundViewSelected.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table_active.png"]];
//    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"g_table-accecory.png"]];
    
    [cell setBackgroundView:tableCellBackgroundView];
    [cell setSelectedBackgroundView:tableCellBackgroundViewSelected];
//    [cell setAccessoryView:accessoryView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kMovieSearchLoadingCellTag) {
        currentPage++;
        if(self.movieID) {
            [self startSimilarSearchWithMovieID:self.movieID];
        } else {
            [self startSearchWithQuery:self.searchQuery];
        }
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.searchResults.count <= indexPath.row) return;
    
    // interent
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
        return;
    }
    
    SearchResult *result = [self.searchResults objectAtIndex:indexPath.row];
    
//    UITableViewCell *clickedCell = [self.tableView cellForRowAtIndexPath:indexPath];
//    UIImageView *coverImageView = (UIImageView *)[clickedCell viewWithTag:kMovieSearchCellImageView];
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    self.addController = nil;
//    self.addController = (AddMovieViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"AddMovieViewController"];
//    self.addController.searchResult = result;
//    self.addController.coverImage = coverImageView.image;
//    self.addController.delegate = self;
    
//    [self presentPopupViewController:self.addController animationType:PopupViewAnimationSlideBottomBottom];

    MoviePopupViewController *popupViewController = [[MoviePopupViewController alloc ] init];
    popupViewController.searchResult = result;
    popupViewController.delegate = self;
    [self presentPopupViewController:popupViewController animationType:PopupViewAnimationSlideBottomBottom];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.searchResults.count) {
        return 42.0f;
    }
    return 79.0f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    view.backgroundColor = [UIColor whiteColor];
//    return view;
//}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewCells

- (void)contextDidSave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (UITableViewCell *)resultCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = kSearchMovieTableViewCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMovieSearchCellTitleLabel];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:kMovieSearchCellYearLabel];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kMovieSearchCellImageView];
    
    SearchResult *currentMovie = [self.searchResults objectAtIndex:indexPath.row];
    
    titleLabel.text = currentMovie.title;
    [titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    
    
    [titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    CGRect yearLabelRect = yearLabel.frame;
    yearLabelRect.origin.y = titleLabel.bottom;
    yearLabel.frame = yearLabelRect;
    yearLabel.text = currentMovie.releaseYear;
    coverImageView.image = nil;
    UIImage *placeholder = [UIImage imageNamed:@"g_placeholder-cover.png"];
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentMovie.posterPath imageType:ImageTypePoster nearWidth:70.0f*2];
    [coverImageView setImageWithURL:imageURL placeholderImage:placeholder];
    
    // if added
    UIImageView *addedImageView = (UIImageView*)[cell viewWithTag:kMovieFlagCellTag];
    addedImageView.alpha = 0.0f;
    BOOL isAdded = [Movie movieWithServerIDExists:[currentMovie.searchResultId integerValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
    if(isAdded) {
        addedImageView.alpha = 1.0f;
    }

    
    
    return cell;
}

- (UITableViewCell *)loadingCell
{
    static NSString *CellIdentifier = kSearchMovieLoadingTableViewCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIImageView *loadingView = (UIImageView*)[cell viewWithTag:75433];
    loadingView.animationImages = [NSArray arrayWithObjects:
                                   [UIImage imageNamed:@"sv_spinner1.png"],
                                   [UIImage imageNamed:@"sv_spinner2.png"],
                                   [UIImage imageNamed:@"sv_spinner3.png"],
                                   [UIImage imageNamed:@"sv_spinner4.png"],
                                   [UIImage imageNamed:@"sv_spinner5.png"],
                                   [UIImage imageNamed:@"sv_spinner6.png"],
                                   [UIImage imageNamed:@"sv_spinner7.png"],
                                   [UIImage imageNamed:@"sv_spinner8.png"],
                                   [UIImage imageNamed:@"sv_spinner9.png"],
                                         nil];
    
    loadingView.animationDuration = 0.8;
    [loadingView startAnimating];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMetaTitleLabelTag];
    titleLabel.text = NSLocalizedString(@"SETTINGS_META_LOADING", nil);
    
    cell.tag = kMovieSearchLoadingCellTag;
    return cell;
}

- (UITableViewCell *)infoCell
{
    static NSString *CellIdentifier = kSearchMovieLoadingTableViewCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *loadingView = (UIImageView*)[cell viewWithTag:75433];
    [loadingView stopAnimating];
    loadingView.image = [UIImage imageNamed:@"sv_error.png"];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMetaTitleLabelTag];
    titleLabel.text = NSLocalizedString(@"SETTINGS_META_NOMOVIES", nil);
    
    [self.searchBar becomeFirstResponder];
    
    cell.tag = kMovieSearchInfoCellTag;
    
    return cell;
}

- (UITableViewCell *)errorCell
{
    static NSString *CellIdentifier = kSearchMovieLoadingTableViewCell;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *loadingView = (UIImageView*)[cell viewWithTag:75433];
    [loadingView stopAnimating];
    loadingView.image = [UIImage imageNamed:@"sv_error.png"];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMetaTitleLabelTag];
    titleLabel.text = NSLocalizedString(@"SETTINGS_META_ERROR", nil);
    
    [self.searchBar becomeFirstResponder];
    
    cell.tag = kMovieSearchInfoCellTag;
    return cell;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISearchBar + Cancel

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
        return;
    }
    
    
    self.searchQuery = aSearchBar.text;
    
    // Reset all the Values
    self.searchResults = nil;
    self.searchResults = [NSMutableArray array];
    currentPage = 0;
    totalPages = 0;
    isLoading = YES;
    isError = NO;
    
    // Start Search
    [self.tableView reloadData];
//    [self startSearchWithQuery:self.searchQuery];
    [aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching

- (void)startSearchWithQuery:(NSString*)query
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithSearchString:query atPage:currentPage completion:^(NSDictionary *results) {
        
        isLoading = NO;
        isError = NO;
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult instanceFromDictionary:movie];
            [self.searchResults addObject:aResult];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        DebugLog("%@", [error localizedDescription]);
        isLoading = NO;
        isError = YES;
        [self.tableView reloadData];
        
    }];
    [operation start];
}

- (void)startSimilarSearchWithMovieID:(NSNumber*)anID
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getSimilarMoviesWithMovieID:anID atPage:currentPage completion:^(NSDictionary *results) {
        isLoading = NO;
        isError = NO;
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult instanceFromDictionary:movie];
            [self.searchResults addObject:aResult];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        isLoading = NO;
        isError = YES;
    }];
    [operation start];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AddMovieViewDelegate

//- (void)AddMovieControllerCancelButtonClicked:(AddMovieViewController *)addMovieViewController
//{
//    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom completion:nil];
//    addController = nil;
//}

- (void)moviePopupCancelButtonClicked:(MoviePopupViewController*)moviePopupViewController
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom completion:nil];
}


@end

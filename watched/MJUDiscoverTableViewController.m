//
//  MJUDiscoverTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import "MJUDiscoverTableViewController.h"
#import "MoviesTableViewCell.h"
#import "AFJSONRequestOperation.h"
#import "OnlineMovieDatabase.h"
#import "SearchResult.h"
#import "MoviesDataModel.h"
#import "Movie.h"
#import "MoviesTableViewLoadingCell.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+Additions.h"
#import "MoviesTableViewLoadingCell.h"
#import "OnlineDatabaseBridge.h"
#import "MovieDetailViewController.h"

const int kMovieTableLoadingCellTag = 2001;

@interface MJUDiscoverTableViewController ()

@end

@implementation MJUDiscoverTableViewController



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = emptyTable;
    
    // Search View
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"SEARCHBAR_PLACEHOLDER", nil);
    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
//    [headerView addSubview:_searchBar];
    self.tableView.tableHeaderView = _searchBar;
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsTableView.delegate = self;
    
    self.searchOperations = [[NSOperationQueue alloc] init];
    [_searchOperations setMaxConcurrentOperationCount:1];
    
    self.searchResults = [NSMutableArray array];
    currentPage = 0;
    totalPages = 0;
    isError = NO;
    isLoading = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if([self needsLoadingCell]) {
        return [self.searchResults count] + 1;
    }
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if([self isSearchIndexPathAtRow:indexPath.row]) {
        cell = [self getLoadingCellForIndexPath:indexPath inTableView:tableView];
        [((MoviesTableViewLoadingCell*)cell).activityIndicator startAnimating];
    } else {
        cell = [self getMoviesTableviewCellForIndexPath:indexPath inTableView:tableView];
        [self configureOnlineSearchResultCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieDiscoverDetailSegue"] && [sender isKindOfClass:[Movie class]]) {
        Movie *currentMovie = (Movie*)sender;
        MovieDetailViewController *detailViewController = (MovieDetailViewController*)segue.destinationViewController;
        detailViewController.movie = currentMovie;
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isSearchIndexPathAtRow:indexPath.row]) {
        return 30.0f;
    }
    return 90.0f;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isSearchIndexPathAtRow:indexPath.row]) return;
    
    SearchResult *result = [self.searchResults objectAtIndex:indexPath.row];
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    [bridge getMovieFromMovieID:result.searchResultId completion:^(Movie *aMovie) {
        [self performSegueWithIdentifier:@"MovieDiscoverDetailSegue" sender:aMovie];
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kMovieTableLoadingCellTag) {
        currentPage++;
        [self startSearch];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Configuring Cells

- (UITableViewCell *)getMoviesTableviewCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)aTableView
{
    static NSString *cellIdentifier = @"DiscoverCell";
    MoviesTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (UITableViewCell *)getLoadingCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)aTableView
{
    static NSString *cellIdentifier = @"DiscoverLoadingCell";
    MoviesTableViewLoadingCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MoviesTableViewLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.tag = kMovieTableLoadingCellTag;
    }
    return cell;
}

- (void)configureOnlineSearchResultCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row > [self.searchResults count]) return;
    
    MoviesTableViewCell *cell = (MoviesTableViewCell*)aCell;
    DebugLog(@"%d - %d", indexPath.row, self.searchResults.count);
    SearchResult *movie = [self.searchResults objectAtIndex:(NSUInteger)indexPath.row];
    cell.titleLabel.text = movie.title;
    [cell.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    // get year
    [cell setYear:movie.releaseDate];
    UIImage *placeholder = [UIImage imageNamed:@"cover-placeholder.png"];
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:movie.posterPath imageType:ImageTypePoster nearWidth:70.0f*2];
    [cell.coverImageView setImageWithURL:imageURL placeholderImage:placeholder];
}

- (BOOL)isSearchIndexPathAtRow:(NSUInteger)row
{
    if(isError) return NO;
    if(currentPage >= totalPages) return NO;
    if(row < [self.searchResults count]) return NO;
    return YES;
}

- (BOOL)needsLoadingCell
{
    if(isError) return NO;
    if(_searchBar.text.length < 1) return NO;
    if(currentPage < totalPages || isLoading) {
        return YES;
    }
    return NO;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching | UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    totalPages = 1;
    currentPage = 0;
    isError = NO;
//    DebugLog(@"%@", _searchOperatiotns);
    [_searchOperations cancelAllOperations];
    [self.searchResults removeAllObjects];
    
}

- (void)startSearch
{
    NSString *searchText = self.searchBar.text;
    DebugLog(@"%@", searchText);
    [self startSearchWithQuery:searchText];
}

- (void)startSearchWithQuery:(NSString*)query
{
    isLoading = YES;
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithSearchString:query atPage:currentPage completion:^(NSDictionary *results) {
        
        isLoading = NO;
        isError = NO;
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult searchResultFromJSONDictionary:movie];
            
            BOOL isAdded = [Movie movieWithServerIDExists:[aResult.searchResultId integerValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
            if(!isAdded) {
                [self.searchResults addObject:aResult];
            }
        }
        [_searchController.searchResultsTableView reloadData];
        
    } failure:^(NSError *error) {
        if([error code] == NSURLErrorCancelled) {
            isLoading = NO;
            isError = NO;
            return;
        }
        
        ErrorLog("%@", [error localizedDescription]);
        isLoading = NO;
        isError = YES;
        [_searchController.searchResultsTableView reloadData];
    }];
    [_searchOperations addOperation:operation];
}


@end

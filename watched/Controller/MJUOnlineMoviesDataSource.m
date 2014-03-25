//
//  MJUOnlineMoviesDataSource.m
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import "MJUOnlineMoviesDataSource.h"
#import "MoviesTableViewLoadingCell.h"
#import "Movie.h"
#import "MovieDetailViewController.h"
#import "SearchResult.h"
#import "MoviesTableViewCell.h"
#import "OnlineDatabaseBridge.h"
#import "OnlineMovieDatabase.h"
#import "UILabel+Additions.h"
#import "UIImageView+AFNetworking.h"
#import "MoviesDataModel.h"
#import "AFJSONRequestOperation.h"
#import "NSString+Additions.h"
#import "AFHTTPRequestOperation.h"

const int kMovieTableLoadingCellTag = 2001;

@implementation MJUOnlineMoviesDataSource


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentPage = 0;
        self.totalPages = 1;
        self.isError = NO;
        self.isLoading = NO;
        
        self.results = [NSMutableArray array];
    }
    return self;
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
    if([self needsLoadingCell]) {
        return [self.results count] + 1;
    }
    return [self.results count];
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
    if(indexPath.row > [self.results count]) return;
    
    MoviesTableViewCell *cell = (MoviesTableViewCell*)aCell;
    SearchResult *movie = [self.results objectAtIndex:(NSUInteger)indexPath.row];
    cell.titleLabel.text = movie.title;
    [cell.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    // get year
    [cell setYear:movie.releaseDate];
    UIImage *placeholder = [UIImage imageNamed:@"cover-placeholder.png"];
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:movie.posterPath imageType:ImageTypePoster nearWidth:70.0f*2];
    [cell.coverImageView setImageWithURL:imageURL placeholderImage:placeholder];
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching

- (void)loadNextResults
{
    self.currentPage++;
    [self startSearch];
}

- (void)startSearch
{
    self.isLoading = YES;
    AFHTTPRequestOperation *operation = [self getRequestObject];
    
    if(!operation) {
        [self searchFailedWithError:nil];
    }
    
    [operation start];
}

- (AFHTTPRequestOperation*)getRequestObject
{
    return nil;
}

- (void)searchSucceededWithMovieDict:(NSDictionary*)results
{
    self.isLoading = NO;
    self.isError = NO;
    
    NSArray *movies = [results objectForKey:@"results"];
    self.totalPages = [[results objectForKey:@"total_pages"] intValue];
    
    for (NSDictionary *movie in movies) {
        SearchResult *aResult = [SearchResult searchResultFromJSONDictionary:movie];
        
        BOOL isAdded = [Movie movieWithServerIDExists:[aResult.searchResultId integerValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
        if(!isAdded) {
            [self.results addObject:aResult];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(searchDataSourceDidReloadData)]) {
        [self.delegate searchDataSourceDidReloadData];
    }
}

- (void)searchFailedWithError:(NSError*)error
{
    if(error && [error code] == NSURLErrorCancelled) {
        self.isLoading = NO;
        self.isError = NO;
        return;
    }
    
    if(error) {
        ErrorLog("%@", [error localizedDescription]);
    }
    
    self.isLoading = NO;
    self.isError = YES;
    
    if ([self.delegate respondsToSelector:@selector(searchDataSourceDidReloadData)]) {
        [self.delegate searchDataSourceDidReloadData];
    }
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Other

- (BOOL)needsLoadingCell
{
    if(self.isError) return NO;
    if(self.currentPage < self.totalPages || self.isLoading) {
        return YES;
    }
    return NO;
}

- (BOOL)isSearchIndexPathAtRow:(NSUInteger)row
{
    if(self.isError) return NO;
    if(self.currentPage >= self.totalPages) return NO;
    if(row < [self.results count]) return NO;
    return YES;
}


@end

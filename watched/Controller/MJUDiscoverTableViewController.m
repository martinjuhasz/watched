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
#import "UITableView+Additions.h"
#import "MJUDiscoverSearchDataSource.h"
#import "MJUDiscoverSearchDelegate.h"

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
    [self.tableView hideEmptyCells];
    
    // Search View
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"SEARCHBAR_PLACEHOLDER", nil);
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    [headerView addSubview:_searchBar];
    self.tableView.tableHeaderView = headerView;
    
    // fixes searchbar not to jump around when focused
    // see: http://stackoverflow.com/questions/20565980/uisearchbar-in-uitableviewheader-strange-animation-on-ios-7
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    self.searchDataSource = [[MJUDiscoverSearchDataSource alloc] init];
    self.searchDataSource.delegate = self;
    
    self.searchDelegate = [[MJUDiscoverSearchDelegate alloc] initWithViewController:self];
    self.searchDelegate.searchDataSource = self.searchDataSource;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    self.searchController.delegate = self.searchDataSource;
    self.searchController.searchResultsDelegate = self.searchDelegate;
    self.searchController.searchResultsDataSource = self.searchDataSource;
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
#pragma mark Searching | UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchDataSource.searchText = searchText;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MJUDiscoverSearchDataSourceDelegate

- (void)searchDataSourceDidReloadData
{
    [self.searchController.searchResultsTableView reloadData];
}



@end

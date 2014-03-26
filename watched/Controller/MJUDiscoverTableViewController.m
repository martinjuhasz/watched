//
//  MJUDiscoverTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import "MJUDiscoverTableViewController.h"
#import "OnlineMovieDatabase.h"
#import "MoviesDataModel.h"
#import "Movie.h"
#import "MovieDetailViewController.h"
#import "UITableView+Additions.h"
#import "MJUDiscoverSearchDataSource.h"
#import "MJUDiscoverSearchDelegate.h"
#import "SearchResult.h"
#import "OnlineDatabaseBridge.h"
#import "MJUDiscoverTableViewCell.h"
#import "MJUOnlineMoviesTableViewController.h"
#import "MJUCuratedDataSource.h"

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
    
    // Discover Items
    self.discoverItems = [NSArray arrayWithObjects:
                          @{
                            @"title": NSLocalizedString(@"DISCOVER_POPULAR", nil),
                            @"icon": [UIImage imageNamed:@"IconDiscoverPopular"]
                            },
                          @{
                            @"title": NSLocalizedString(@"DISCOVER_UPCOMING", nil),
                            @"icon": [UIImage imageNamed:@"IconDiscoverUpcoming"]
                            },
                          @{
                            @"title": NSLocalizedString(@"DISCOVER_INTHEATERS", nil),
                            @"icon": [UIImage imageNamed:@"IconDiscoverTheaters"]
                            }
                          , nil];
    
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
    self.searchController.searchResultsDelegate = self.searchDelegate;
    self.searchController.searchResultsDataSource = self.searchDataSource;

}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieDiscoverDetailSegue"] && [sender isKindOfClass:[NSIndexPath class]]) {
        
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        
        // TODO: get Movie inside DetailViewController, not inside DiscoverVC
        SearchResult *result = [self.searchDataSource.results objectAtIndex:indexPath.row];
        OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
        [bridge getMovieFromMovieID:result.searchResultId completion:^(Movie *aMovie) {
            MovieDetailViewController *detailViewController = (MovieDetailViewController*)segue.destinationViewController;
            detailViewController.movie = aMovie;
        } failure:^(NSError *error) {
            ErrorLog(@"%@", [error localizedDescription]);
        }];
        
        
    } else if([segue.identifier isEqualToString:@"CuratedMoviesSegue"] && [sender isKindOfClass:[NSIndexPath class]]) {
        
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        MJUOnlineMoviesTableViewController *destinationViewController = (MJUOnlineMoviesTableViewController*)segue.destinationViewController;
        
        if(indexPath.row == 0) {
            [destinationViewController setDataSourceType:MJUCuratedDataSourceTypePopular];
        } else if(indexPath.row == 1) {
            [destinationViewController setDataSourceType:MJUCuratedDataSourceTypeUpcoming];
        } else if(indexPath.row == 2) {
            [destinationViewController setDataSourceType:MJUCuratedDataSourceTypeInTheathers];
        }
    }
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
    return [self.discoverItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MJUDiscoverCell";
    MJUDiscoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MJUDiscoverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *item = [self.discoverItems objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.imageView.image = [item objectForKey:@"icon"];
    
    if(indexPath.row >= (self.discoverItems.count - 1)) {
        cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    
    return cell;
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"CuratedMoviesSegue" sender:indexPath];
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

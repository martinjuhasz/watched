//
//  SearchMovieViewController.m
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchMovieViewController.h"
#import "OnlineMovieDatabase.h"
#import "SearchResult.h"
#import "UIImageView+AFNetworking.h"
#import "SearchMoviePopupViewController.h"


@implementation SearchMovieViewController

@synthesize tableView;
@synthesize searchResults;

const int kLoadingCellTag = 2000;
const int kMovieCellTitleLabel = 100;
const int kMovieCellYearLabel = 101;
const int kMovieCellImageView = 200;


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
    
    currentPage = 1;
    self.searchResults = [NSMutableArray array];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MoviePopup"]) {
        SearchMoviePopupViewController *popupViewController = segue.destinationViewController;
        NSLog(@"%@", popupViewController);
//        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
//        DetailViewController *detailViewController = [segue destinationViewController];
//        detailViewController.play = [dataController objectInListAtIndex:selectedRowIndex.row];
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
    // display extra loading cell if there are some results
    if(self.searchResults > 0 && totalPages > currentPage) {
        return self.searchResults.count + 1;
    }
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check to see if loading cell needs to be displayed
    if (indexPath.row < self.searchResults.count) {
        return [self resultCellAtIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kLoadingCellTag) {
        currentPage++;
        [self startSearchWithQuery:searchQuery];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewCells

- (UITableViewCell *)resultCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchMovieTableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMovieCellTitleLabel];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:kMovieCellYearLabel];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kMovieCellImageView];
    
    SearchResult *currentMovie = [self.searchResults objectAtIndex:indexPath.row];
    
    titleLabel.text = currentMovie.title;
    yearLabel.text = currentMovie.releaseYear;
    coverImageView.image = nil;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentMovie.posterPath imageType:imageTypePoster nearWidth:70.0f*2];
    [coverImageView setImageWithURL:imageURL];

    return cell;
}

- (UITableViewCell *)loadingCell
{
    static NSString *CellIdentifier = @"SearchMovieLoadingTableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.tag = kLoadingCellTag;
    return cell;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    searchQuery = aSearchBar.text;
    
    // Reset all the Values
    self.searchResults = nil;
    self.searchResults = [NSMutableArray array];
    currentPage = 1;
    totalPages = 0;
    [self.tableView reloadData];
    
    // Start Search
    [self startSearchWithQuery:searchQuery];
    [aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching

- (void)startSearchWithQuery:(NSString*)query
{
    [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithSearchString:query atPage:currentPage completion:^(NSDictionary *results) {
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult instanceFromDictionary:movie];
            [self.searchResults addObject:aResult];
        }
        [self.tableView reloadData];
    }];
}



@end

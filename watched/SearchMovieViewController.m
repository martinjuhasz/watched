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
#import "MBProgressHUD.h"
#import "UISearchBar+Additions.h"
#import "OnlineDatabaseBridge.h"
#import "Movie.h"

@implementation SearchMovieViewController

@synthesize tableView;
@synthesize searchBar;
@synthesize searchResults;

const int kMovieSearchLoadingCellTag = 2000;
const int kMovieSearchCellTitleLabel = 100;
const int kMovieSearchCellYearLabel = 101;
const int kMovieSearchCellImageView = 200;


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
    
    currentPage = 1;
    self.searchResults = [NSMutableArray array];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kMovieSearchLoadingCellTag) {
        currentPage++;
        [self startSearchWithQuery:searchQuery];
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchResult *result = [searchResults objectAtIndex:indexPath.row];
    [self saveMovieToDatabase:result];
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
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMovieSearchCellTitleLabel];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:kMovieSearchCellYearLabel];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kMovieSearchCellImageView];
    
    SearchResult *currentMovie = [self.searchResults objectAtIndex:indexPath.row];
    
    titleLabel.text = currentMovie.title;
    yearLabel.text = currentMovie.releaseYear;
    coverImageView.image = nil;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentMovie.posterPath imageType:ImageTypePoster nearWidth:70.0f*2];
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
    cell.tag = kMovieSearchLoadingCellTag;
    return cell;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISearchBar + Cancel

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

- (IBAction)cancelButtonClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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
    } failure:^(NSError *error) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.dimBackground = YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = [error localizedDescription];
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0f];
    }];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase:(SearchResult*)result
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    
//    bridge.completionBlock = ^(Movie *aMovie) {
//        [self sendHUDCompletionMessage:@"Movie added" hud:hud];
//    };
//    
//    bridge.failureBlock = ^(NSError *error) {
//        NSString *errorMessage = @"Unknown Error. Please contact us if this problem exists.";
//        
//        if([error.domain isEqualToString:kBridgeErrorDomain]) {
//            errorMessage = [self getErrorMessageForBridgeError:error.code];
//        } else if([error.domain isEqualToString:AFNetworkingErrorDomain]) {
//            errorMessage = @"Online Database not responding, please try again";
//        }
//        [self sendHUDCompletionMessage:errorMessage hud:hud];
//    };
    
    [bridge saveSearchResultAsMovie:result completion:^(Movie *aMovie) {
        
        [self sendHUDCompletionMessage:@"Movie added" hud:hud];
    
    } failure:^(NSError *error) {
        
        NSString *errorMessage = @"Unknown Error. Please contact us if this problem exists.";
        if([error.domain isEqualToString:kBridgeErrorDomain]) {
            errorMessage = [self getErrorMessageForBridgeError:error.code];
        } else if([error.domain isEqualToString:AFNetworkingErrorDomain]) {
            errorMessage = @"Online Database not responding, please try again";
        }
        [self sendHUDCompletionMessage:errorMessage hud:hud];
    }];
        
}

- (void)sendHUDCompletionMessage:(NSString*)message hud:(MBProgressHUD*)aHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        aHud.mode = MBProgressHUDModeText;
        aHud.labelText = message;
        aHud.removeFromSuperViewOnHide = YES;
        [aHud hide:YES afterDelay:1.0f];
    });
}

- (NSString*)getErrorMessageForBridgeError:(BridgeError)aErrorCode
{
    NSString *errorMessage = @"";
    if(aErrorCode == BridgeErrorMovieExists) {
        errorMessage = @"Movie already added";
    }
    return errorMessage;
}


@end

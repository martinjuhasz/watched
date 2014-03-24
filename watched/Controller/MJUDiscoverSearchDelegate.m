//
//  MJUDiscoverSearchDelegate.m
//  watched
//
//  Created by Martin Juhasz on 24/03/14.
//
//

#import "MJUDiscoverSearchDelegate.h"
#import "MJUDiscoverSearchDataSource.h"
#import "SearchResult.h"
#import "OnlineDatabaseBridge.h"
#import "MoviesTableViewLoadingCell.h"

@implementation MJUDiscoverSearchDelegate


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject

- (instancetype)initWithViewController:(UITableViewController*)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.searchDataSource isSearchIndexPathAtRow:indexPath.row]) {
        return 30.0f;
    }
    return 90.0f;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.searchDataSource isSearchIndexPathAtRow:indexPath.row]) return;
    
    SearchResult *result = [self.searchDataSource.searchResults objectAtIndex:indexPath.row];
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    [bridge getMovieFromMovieID:result.searchResultId completion:^(Movie *aMovie) {
        if(self.viewController) {
            [self.viewController performSegueWithIdentifier:@"MovieDiscoverDetailSegue" sender:aMovie];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[MoviesTableViewLoadingCell class]]) {
        [self.searchDataSource loadNextResults];
    }
}

@end

//
//  MJUDiscoverSearchDataSource.m
//  watched
//
//  Created by Martin Juhasz on 24/03/14.
//
//

#import "MJUDiscoverSearchDataSource.h"
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

@implementation MJUDiscoverSearchDataSource


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


- (void)setSearchText:(NSString *)searchText
{
    if(![_searchText isEqualToString:searchText]) {
        _searchText = searchText;
        [self resetSearch];
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching

- (void)resetSearch
{
    self.totalPages = 1;
    self.currentPage = 0;
    self.isError = NO;
    
    [self.results removeAllObjects];
}

- (AFHTTPRequestOperation*)getRequestObject
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithSearchString:self.searchText atPage:self.currentPage completion:^(NSDictionary *results) {
        [self searchSucceededWithMovieDict:results];
    } failure:^(NSError *error) {
        [self searchFailedWithError:error];
    }];
    return operation;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Other

- (BOOL)needsLoadingCell
{
    if(self.searchText.length < 1) return NO;
    return [super needsLoadingCell];
}


@end

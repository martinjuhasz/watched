//
//  MJUOnlineMoviesDataSource.h
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import <UIKit/UIKit.h>
#import "MJUDiscoverSearchDataSourceDelegate.h"

@interface MJUOnlineMoviesDataSource : NSObject<UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *results;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalPages;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isError;
@property (weak, nonatomic) id <MJUDiscoverSearchDataSourceDelegate> delegate;

- (BOOL)isSearchIndexPathAtRow:(NSUInteger)row;
- (void)loadNextResults;
- (BOOL)needsLoadingCell;
- (void)searchSucceededWithMovieDict:(NSDictionary*)results;
- (void)searchFailedWithError:(NSError*)error;

@end

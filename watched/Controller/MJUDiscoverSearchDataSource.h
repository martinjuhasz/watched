//
//  MJUDiscoverSearchDataSource.h
//  watched
//
//  Created by Martin Juhasz on 24/03/14.
//
//

#import <UIKit/UIKit.h>
#import "MJUDiscoverSearchDataSourceDelegate.h"


@interface MJUDiscoverSearchDataSource : NSObject<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSOperationQueue *searchOperations;
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalPages;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isError;
@property (weak, nonatomic) id <MJUDiscoverSearchDataSourceDelegate> delegate;

- (BOOL)isSearchIndexPathAtRow:(NSUInteger)row;
- (void)loadNextResults;

@end
//
//  SearchMovieViewController.h
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchedStyledViewController.h"

@class SearchResult;

@interface SearchMovieViewController : WatchedStyledViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    NSInteger currentPage;
    NSInteger totalPages;
    BOOL isLoading;
    BOOL isError;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) NSString *searchQuery;
@property (strong, nonatomic) NSNumber *movieID;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (UITableViewCell *)resultCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)loadingCell;
- (void)startSearchWithQuery:(NSString*)query;
- (IBAction)cancelButtonClicked:(id)sender;

@end

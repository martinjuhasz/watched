//
//  SearchMovieViewController.h
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;
@class AddMovieViewController;

@interface SearchMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    NSString *searchQuery;
    NSInteger currentPage;
    NSInteger totalPages;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) AddMovieViewController *addController;

- (UITableViewCell *)resultCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)loadingCell;
- (void)startSearchWithQuery:(NSString*)query;
- (IBAction)cancelButtonClicked:(id)sender;

@end

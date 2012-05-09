//
//  SearchMovieViewController.h
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;

@interface SearchMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    NSString *searchQuery;
    NSInteger currentPage;
    NSInteger totalPages;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchResults;

- (UITableViewCell *)resultCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)loadingCell;
- (void)startSearchWithQuery:(NSString*)query;
- (void)saveMovieToDatabase:(SearchResult*)result;

@end

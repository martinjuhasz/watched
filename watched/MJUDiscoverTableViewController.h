//
//  MJUDiscoverTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import <UIKit/UIKit.h>

@interface MJUDiscoverTableViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate> {
    NSInteger currentPage;
    NSInteger totalPages;
    BOOL isLoading;
    BOOL isError;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) NSOperationQueue *searchOperations;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

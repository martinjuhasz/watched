//
//  MoviesTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 09.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef enum {
    MovieSortTypeAll = 1,
    MovieSortTypeUnwatched,
    MovieSortTypeUnrated
} MovieSortType;

typedef enum {
    MovieCellTypeDefault = 1,
    MovieCellTypeLoading,
    MovieCellTypeOnline,
    MovieCellTypeError,
    MovieCellTypeAdding
} MovieCellType;

typedef enum {
    SearchSectionTypeFound = 1,
    SearchSectionTypeAdded,
    SearchSectionTypeOnline
} SearchSectionType;

@interface MoviesTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate>
{
    NSInteger currentPage;
    NSInteger totalPages;
    BOOL isLoading;
    BOOL isError;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) MovieSortType currentSortType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sortControl;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) NSOperationQueue *searchOperations;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *addedSearchResults;
@property (strong, nonatomic) NSIndexPath *detailedCell;

@end

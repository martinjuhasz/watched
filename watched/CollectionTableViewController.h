//
//  MoviesTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 09.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


typedef NS_ENUM(NSInteger, MovieSortType) {
    MovieSortTypeAll,
    MovieSortTypeUnwatched,
    MovieSortTypeUnrated
};

@interface CollectionTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchedResultsController *searchFetchedResultsController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) MovieSortType currentSortType;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;

@end

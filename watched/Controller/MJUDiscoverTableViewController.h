//
//  MJUDiscoverTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MJUDiscoverSearchDataSourceDelegate.h"

@class MJUDiscoverSearchDataSource;
@class MJUDiscoverSearchDelegate;

@interface MJUDiscoverTableViewController : UITableViewController<UISearchBarDelegate, MJUDiscoverSearchDataSourceDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) MJUDiscoverSearchDataSource *searchDataSource;
@property (strong, nonatomic) MJUDiscoverSearchDelegate *searchDelegate;
@property (strong, nonatomic) NSArray *discoverItems;

@end

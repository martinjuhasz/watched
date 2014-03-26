//
//  OnlineMoviesTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import "MJUOnlineMoviesTableViewController.h"
#import "MJUOnlineMoviesDataSource.h"
#import "MJUDiscoverSearchDelegate.h"

@interface MJUOnlineMoviesTableViewController ()

@end

@implementation MJUOnlineMoviesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchDelegate = [[MJUDiscoverSearchDelegate alloc] initWithViewController:self];
    self.searchDelegate.searchDataSource = self.dataSource;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.searchDelegate;
}

- (MJUCuratedDataSource*)dataSource
{
    if(!_dataSource) {
        _dataSource = [[MJUCuratedDataSource alloc] init];
        _dataSource.delegate = self;
        [self setDataSourceType:MJUCuratedDataSourceTypeInTheathers];
    }
    return _dataSource;
}

- (void)setDataSourceType:(MJUCuratedDataSourceType)type
{
    self.dataSource.dataSourceType = type;
    
    if(type == MJUCuratedDataSourceTypeInTheathers) {
        self.title = NSLocalizedString(@"DISCOVER_INTHEATERS", nil);
    } else if(type == MJUCuratedDataSourceTypePopular) {
        self.title = NSLocalizedString(@"DISCOVER_POPULAR", nil);
    } else if(type == MJUCuratedDataSourceTypeUpcoming) {
        self.title = NSLocalizedString(@"DISCOVER_UPCOMING", nil);
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MJUDiscoverSearchDataSourceDelegate

- (void)searchDataSourceDidReloadData
{
    [self.tableView reloadData];
}


@end

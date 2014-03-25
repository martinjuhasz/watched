//
//  OnlineMoviesTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import <UIKit/UIKit.h>
#import "MJUDiscoverSearchDataSourceDelegate.h"
#import "MJUCuratedDataSource.h"

@class MJUCuratedDataSource;
@class MJUDiscoverSearchDelegate;

@interface MJUOnlineMoviesTableViewController : UITableViewController<MJUDiscoverSearchDataSourceDelegate>

@property (strong, nonatomic) MJUCuratedDataSource *dataSource;
@property (strong, nonatomic) MJUDiscoverSearchDelegate *searchDelegate;

- (void)setDataSourceType:(MJUCuratedDataSourceType)type;

@end

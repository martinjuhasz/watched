//
//  MJUDiscoverSearchDelegate.h
//  watched
//
//  Created by Martin Juhasz on 24/03/14.
//
//

#import <Foundation/Foundation.h>

@class MJUOnlineMoviesDataSource;

@interface MJUDiscoverSearchDelegate : NSObject<UITableViewDelegate>

@property (strong, nonatomic) MJUOnlineMoviesDataSource *searchDataSource;
@property (weak, nonatomic) UITableViewController *viewController;

- (instancetype)initWithViewController:(UITableViewController*)viewController;

@end

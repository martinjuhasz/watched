//
//  MJUDiscoverSearchDataSource.h
//  watched
//
//  Created by Martin Juhasz on 24/03/14.
//
//

#import <UIKit/UIKit.h>
#import "MJUOnlineMoviesDataSource.h"


@interface MJUDiscoverSearchDataSource : MJUOnlineMoviesDataSource

@property (strong, nonatomic) NSString *searchText;

@end
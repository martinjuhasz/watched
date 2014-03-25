//
//  MJUCuratedDataSource.h
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import "MJUOnlineMoviesDataSource.h"

typedef NS_ENUM(NSInteger, MJUCuratedDataSourceType) {
    MJUCuratedDataSourceTypeInTheathers,
    MJUCuratedDataSourceTypeUpcoming,
    MJUCuratedDataSourceTypePopular
};


@interface MJUCuratedDataSource : MJUOnlineMoviesDataSource

@property (assign, nonatomic) MJUCuratedDataSourceType dataSourceType;

@end

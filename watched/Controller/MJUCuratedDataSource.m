//
//  MJUCuratedDataSource.m
//  watched
//
//  Created by Martin Juhasz on 25/03/14.
//
//

#import "MJUCuratedDataSource.h"
#import "AFJSONRequestOperation.h"
#import "OnlineMovieDatabase.h"

@implementation MJUCuratedDataSource

- (AFHTTPRequestOperation*)getRequestObject
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithCuratedType:self.dataSourceType atPage:self.currentPage completion:^(NSDictionary *results) {
        [self searchSucceededWithMovieDict:results];
    } failure:^(NSError *error) {
        [self searchFailedWithError:error];
    }];
    return operation;
}

@end

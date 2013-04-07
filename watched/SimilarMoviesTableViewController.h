//
//  SimilarMoviesTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 19.03.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    MovieCellTypeDefault = 1,
    MovieCellTypeLoading,
    MovieCellTypeOnline,
    MovieCellTypeError,
    MovieCellTypeAdding
} MovieCellType;

@class Movie;

@interface SimilarMoviesTableViewController : UITableViewController{
    NSInteger currentPage;
    NSInteger totalPages;
    BOOL isLoading;
    BOOL isError;
}

@property (strong, nonatomic) Movie *movie;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *addedSearchResults;

@end

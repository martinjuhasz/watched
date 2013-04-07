//
//  SimilarMoviesTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 19.03.13.
//
//

#import "SimilarMoviesTableViewController.h"
#import "Movie.h"
#import "MoviesTableViewCell.h"
#import "MoviesTableViewLoadingCell.h"
#import "AFJSONRequestOperation.h"
#import "OnlineMovieDatabase.h"
#import "SearchResult.h"
#import "UIImageView+AFNetworking.h"
#import "MoviesDataModel.h"
#import "MJCustomAccessoryControl.h"
#import "MJLoadingAccessoryControl.h"
#import "MovieDetailViewController.h"
#import "OnlineDatabaseBridge.h"
#import "UILabel+Additions.h"

#define kSimilarMovieTableLoadingCell @"kSimilarMovieTableLoadingCell"
#define kSimilarMovieTableErrorCell @"kSimilarMovieTableOnlineCell"
#define kSimilarMovieTableOnlineCell @"kSimilarMovieTableErrorCell"
#define kSimilarMovieTableAddingCell @"kSimilarMovieTableAddingCell"


const int kSimilarMovieTableLoadingCellTag = 2001;
const int kSimilarMovieTableErrorCellTag = 2002;
const int kSimilarMovieTableOnlineCellTag = 2003;
const int kSimilarMovieTableAddingCellTag = 2004;

@interface SimilarMoviesTableViewController ()

@end

@implementation SimilarMoviesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"BUTTON_SIMILAR", nil);
    
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectZero];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = emptyTable;
    
    currentPage = 0;
    isError = NO;
    isLoading = YES;
    
    self.searchResults = [NSMutableArray array];
    self.addedSearchResults = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[[MoviesDataModel sharedDataModel] mainContext]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // first search
    if(isLoading) return 1;
    
    // Error
    if(isError) return self.searchResults.count;
    
    // no result
    if(!isLoading && self.searchResults.count == 0) return 0;
    
    // display extra loading cell if there are some results
    if(self.searchResults.count > 0 && totalPages > currentPage) {
        return self.searchResults.count + 1;
    }
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier;
    
    if (indexPath.row < self.searchResults.count) {
        cellIdentifier = kSimilarMovieTableOnlineCell;
        cell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.tag = kSimilarMovieTableOnlineCellTag;
        [self configureOnlineSearchResultCell:cell atIndexPath:indexPath];
    } else {
        cellIdentifier = kSimilarMovieTableLoadingCell;
        cell = [[MoviesTableViewLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = kSimilarMovieTableLoadingCellTag;
    }
    
    return cell;
}

- (void)startSimilarSearch
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getSimilarMoviesWithMovieID:self.movie.movieID atPage:currentPage completion:^(NSDictionary *results) {
        isLoading = NO;
        isError = NO;
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult instanceFromDictionary:movie];
            [self.searchResults addObject:aResult];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        isLoading = NO;
        isError = YES;
        [self.tableView reloadData];
    }];
    [operation start];
}

- (void)configureOnlineSearchResultCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    MoviesTableViewCell *cell = (MoviesTableViewCell*)aCell;
    
    SearchResult *aMovie = [self.searchResults objectAtIndex:(NSUInteger)indexPath.row];
    cell.titleLabel.text = aMovie.title;
    [cell.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    // get year
    [cell setYear:aMovie.releaseDate];
    UIImage *placeholder = [UIImage imageNamed:@"g_placeholder-cover.png"];
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:aMovie.posterPath imageType:ImageTypePoster nearWidth:70.0f*2];
    [cell.coverImageView setImageWithURL:imageURL placeholderImage:placeholder];
    
    // custom accecory control
    NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
    int movieID = [[aMovie searchResultId] intValue];
    Movie *foundMovie = [Movie movieWithServerId:movieID usingManagedObjectContext:mainContext];
    if([self.addedSearchResults containsObject:aMovie]) {
        cell.accessoryView = [MJLoadingAccessoryControl accessory];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if(foundMovie) {
        cell.accessoryView = [MJCustomAccessoryControl accessory];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieDetailSegue"] && [sender isKindOfClass:[Movie class]]) {
        MovieDetailViewController *detailViewController = (MovieDetailViewController*)segue.destinationViewController;
        detailViewController.movie = (Movie*)sender;
    }
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase:(SearchResult*)aSearchResult atIndexPath:(NSIndexPath*)oldIndexPath
{
    [self.tableView beginUpdates];
    [self.addedSearchResults addObject:aSearchResult];
    [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
 
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    AFJSONRequestOperation *operation = [bridge saveSearchResultAsMovie:aSearchResult completion:^(Movie *movie) {
        aSearchResult.added = YES;
        [self.addedSearchResults removeObject:aSearchResult];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    } failure:^(NSError *error) {
        DebugLog("%@", [error localizedDescription]);
        [self.addedSearchResults removeObject:aSearchResult];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }];
    [operation start];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kSimilarMovieTableLoadingCellTag) {
        currentPage++;
        [self startSimilarSearch];
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.searchResults.count) {
        return 43.0f;
    }
    return 79.0f;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.searchResults.count) return;
    
    SearchResult *aMovie = [self.searchResults objectAtIndex:(NSUInteger)indexPath.row];
    NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
    int movieID = [[aMovie searchResultId] intValue];
    Movie *foundMovie = [Movie movieWithServerId:movieID usingManagedObjectContext:mainContext];
    if(foundMovie == nil && ![self.addedSearchResults containsObject:aMovie]) {
        [self saveMovieToDatabase:aMovie atIndexPath:indexPath];
    } else if(foundMovie) {
        [self performSegueWithIdentifier:@"MovieDetailSegue" sender:foundMovie];
    }
}

- (void)handleDataModelChange:(NSNotification *)note
{
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[Movie class]];
    }];
    NSSet *filteredSet = [deletedObjects filteredSetUsingPredicate:pred];
    [self.tableView beginUpdates];
    for (Movie *aMovie in filteredSet) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchResultId == %@", aMovie.movieID];
        NSArray *movies = [self.searchResults filteredArrayUsingPredicate:predicate];
        for (SearchResult *aResult in movies) {
            NSInteger row = [self.searchResults indexOfObject:aResult];
            if([self.addedSearchResults containsObject:aResult]) {
                [self.addedSearchResults removeObject:aResult];
            }
            aResult.added = NO;
            NSIndexPath *reloadPath = [NSIndexPath indexPathForItem:row inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[reloadPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [self.tableView endUpdates];
}




@end

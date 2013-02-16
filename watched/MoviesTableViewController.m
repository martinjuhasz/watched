//
//  MoviesTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoviesTableViewController.h"
#import "Movie.h"
#import "MoviesDataModel.h"
#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+Additions.h"
#import "MJCustomAccessoryControl.h"
#import "UIView+Additions.h"
#import "AFJSONRequestOperation.h"
#import "OnlineMovieDatabase.h"
#import "SearchResult.h"
#import "MoviesTableViewCell.h"
#import "MoviesTableViewLoadingCell.h"
#import "OnlineDatabaseBridge.h"
#import "MoviesTableViewOnlineCell.h"

#define kSectionHeaderHeight 24.0f

#define kMovieTableDefaultCell @"kMovieTableDefaultCell"
#define kMovieTableLoadingCell @"kMovieTableLoadingCell"
#define kMovieTableErrorCell @"kMovieTableOnlineCell"
#define kMovieTableOnlineCell @"kMovieTableErrorCell"

const int kMovieTableDefaultCellTag = 2000;
const int kMovieTableLoadingCellTag = 2001;
const int kMovieTableErrorCellTag = 2002;
const int kMovieTableOnlineCellTag = 2003;

@interface MoviesTableViewController ()
- (void)loadMoviesWithSortType:(MovieSortType)sortType;
@end




@implementation MoviesTableViewController

@synthesize tableView;
@synthesize currentSortType;
@synthesize addButton;
@synthesize addButtonBackgroundView;
@synthesize sortControl;


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"OVERVIEW_TITLE", nil);
    
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = emptyTable;
    
    // Search View
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsTableView.delegate = self;
    self.searchOperations = [[NSOperationQueue alloc] init];
    [_searchOperations setMaxConcurrentOperationCount:1];
    
    self.searchResults = [NSMutableArray array];
    currentPage = 0;
    totalPages = 1;
    isError = NO;
    isLoading = NO;
    
    // Add Button
    UIImage *addButtonBgImage = [[UIImage imageNamed:@"mv_addbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 8, 26, 8)];
    UIImage *addButtonBgImageActive = [[UIImage imageNamed:@"mv_addbutton_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 8, 26, 8)];
    [self.addButton setBackgroundImage:addButtonBgImage forState:UIControlStateNormal];
    [self.addButton setBackgroundImage:addButtonBgImageActive forState:UIControlStateHighlighted];
    [self.addButton setTitleColor:HEXColor(0xFFFFFF) forState:UIControlStateNormal];
    [self.addButton setTitleShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.33f] forState:UIControlStateNormal];
    [[self.addButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    self.addButtonBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mv_bg_add.png"]];
    [self.addButton setTitle:NSLocalizedString(@"BUTTON_ADDMOVIE_TITLE", nil) forState:UIControlStateNormal];
    
    // Segmented Control
    [self.sortControl setTitle:NSLocalizedString(@"CONTROL_SORTMOVIES_TITLE_ALL", nil) forSegmentAtIndex:0];
    [self.sortControl setTitle:NSLocalizedString(@"CONTROL_SORTMOVIES_TITLE_UNWATCHED", nil) forSegmentAtIndex:1];
    [self.sortControl setTitle:NSLocalizedString(@"CONTROL_SORTMOVIES_TITLE_UNRATED", nil) forSegmentAtIndex:2];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:nil];
    
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    
    [self setAddButton:nil];
    [self setAddButtonBackgroundView:nil];
    [self setSortControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    NSFetchedResultsController *currentController = [self fetchedResultsControllerForTableView:aTableView];
    if([currentController isEqual:self.searchFetchedResultsController]) {
        return [[currentController sections] count] + 1;
    }
    return [[currentController sections] count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if([self isOnlineSearchSectionInTableView:aTableView currentSection:section]) {
        if(currentPage < totalPages) {
            return [self.searchResults count] + 1;
        } else {
            return [self.searchResults count];
        }
    }
    id<NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:aTableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if([self isOnlineSearchSectionInTableView:aTableView currentSection:section]) {
        return @"HEADER_TITLE_ONLINESEARCH";
    }
    
    // without headers
    if(currentSortType != MovieSortTypeAll) return nil;
    NSString *star = [[[[self fetchedResultsControllerForTableView:aTableView] sections] objectAtIndex:section] name];
    if([star isEqualToString:@"0"]) star = NSLocalizedString(@"HEADER_TITLE_ZERORATING", nil);
    return star;
}

- (UITableViewCell*)createCellWithType:(MovieCellType)cellType onTableView:(UITableView*)aTableView
{
    static NSString *cellIdentifier;
    UITableViewCell *cell = nil;
    int tag;
    
    if(cellType == MovieCellTypeDefault) {
        cellIdentifier = kMovieTableDefaultCell;
        tag = kMovieTableDefaultCellTag;
    } else if (cellType == MovieCellTypeLoading) {
        cellIdentifier = kMovieTableLoadingCell;
        tag = kMovieTableLoadingCellTag;
    } else if(cellType == MovieCellTypeOnline) {
        cellIdentifier = kMovieTableOnlineCell;
        tag = kMovieTableOnlineCellTag;
    } else {
        cellIdentifier = kMovieTableErrorCell;
        tag = kMovieTableErrorCellTag;
    }
    
    cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if(cellType == MovieCellTypeDefault) {
            cell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } else if (cellType == MovieCellTypeLoading) {
            cell = [[MoviesTableViewLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } else if (cellType == MovieCellTypeOnline) {
            cell = [[MoviesTableViewOnlineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }  else {
            cell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    cell.tag = tag;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieCellType cellType = [self cellTypeForTableView:aTableView indexPath:indexPath];
    UITableViewCell *cell = [self createCellWithType:cellType onTableView:aTableView];
    
    
    if(cellType == MovieCellTypeDefault) {
        [self fetchedResultsController:[self fetchedResultsControllerForTableView:aTableView] configureCell:cell atIndexPath:indexPath];
    } else if(cellType == MovieCellTypeLoading) {
        [self configureLoadingCell:cell atIndexPath:indexPath];
    } else if(cellType == MovieCellTypeOnline) {
        [self configureOnlineSearchResultCell:cell atIndexPath:indexPath];
    } else {
        // ERROR
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![self isOnlineSearchSectionInTableView:aTableView currentSection:indexPath.section];
}

- (void)fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    MoviesTableViewCell *cell = (MoviesTableViewCell*)aCell;
    
    Movie *movie = [aFetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = movie.title;
    [cell.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    // get year
    [cell setYear:movie.releaseDate];
    [cell setCoverImage:movie.posterThumbnail];
}

- (void)configureOnlineSearchResultCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    MoviesTableViewOnlineCell *cell = (MoviesTableViewOnlineCell*)aCell;
    
    SearchResult *movie = [self.searchResults objectAtIndex:(NSUInteger)indexPath.row];
    cell.titleLabel.text = movie.title;
    //[cell.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    // get year
    //[cell setYear:movie.releaseDate];
    UIImage *placeholder = [UIImage imageNamed:@"g_placeholder-cover.png"];
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:movie.posterPath imageType:ImageTypePoster nearWidth:70.0f*2];
    [cell.coverImageView setImageWithURL:imageURL placeholderImage:placeholder];
}

- (void)configureLoadingCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    MoviesTableViewLoadingCell *cell = (MoviesTableViewLoadingCell*)aCell;
    [cell.loadingView startAnimating];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:aTableView titleForHeaderInSection:section] != nil) {
        return kSectionHeaderHeight-1;
    }
    
   return 0;
}

- (UIView*)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:aTableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    int rating = [sectionTitle intValue];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, 320, kSectionHeaderHeight)];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -1.0f, 320, kSectionHeaderHeight)];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mv_sectionheader.png"]];
    
    if(rating > 0) {
        UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 18.0f*rating, 14.0f)];
        [starView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mv_sectionheader-star.png"]]];
        [backgroundView addSubview:starView];
    } else {
        UILabel *unratedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 320.0f, kSectionHeaderHeight-1.0f)];
        unratedLabel.backgroundColor = [UIColor clearColor];
        unratedLabel.textColor = [UIColor whiteColor];
        unratedLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
        unratedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        unratedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f];
        unratedLabel.text = sectionTitle;
        [backgroundView addSubview:unratedLabel];
    }
    
    [headerView addSubview:backgroundView];
    return headerView;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isOnlineSearchSectionInTableView:aTableView currentSection:indexPath.section]) {
        [self saveMovieToDatabase:[[self searchResults] objectAtIndex:(NSUInteger)indexPath.row]];
    } else {
        [self performSegueWithIdentifier:@"MovieDetailSegue" sender:self];
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MovieCellType cellType = [self cellTypeForTableView:aTableView indexPath:indexPath];
    if(cellType == MovieCellTypeLoading || cellType == MovieCellTypeOnline) {
        return 44.0f;
    }
    return 78.0f;
}



- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Movie *aMovie = nil;
        NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
        aMovie = [[self fetchedResultsControllerForTableView:aTableView] objectAtIndexPath:indexPath];

        NSError *error;
        [mainContext deleteObject:aMovie];
        [mainContext save:&error];
    
        if(error) {
            ErrorLog("%@", [error localizedDescription]);
        }        
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewForResultsController:controller] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewForResultsController:controller] endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *aTableView = [self tableViewForResultsController:controller];
    
    if (type == NSFetchedResultsChangeDelete) {
        [aTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(type == NSFetchedResultsChangeInsert) {
        [aTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(type == NSFetchedResultsChangeMove) {
        if (newIndexPath == nil) return;
        [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [aTableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        //[aTableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    else {
        [aTableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if(type == NSFetchedResultsChangeDelete) {
        [[self tableViewForResultsController:controller] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(type == NSFetchedResultsChangeInsert) {
        [[self tableViewForResultsController:controller] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kMovieTableLoadingCellTag) {
        currentPage++;
        [self startSearch];
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieDetailSegue"]) {
        MovieDetailViewController *detailViewController = (MovieDetailViewController*)segue.destinationViewController;
        detailViewController.movie = [[self activeFetchedResultsController] objectAtIndexPath:[[self activeTableView] indexPathForSelectedRow]];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CoreData Handling

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Movie entityName]];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"title", nil]];
    [fetchRequest setFetchBatchSize:40];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    // Filter by SortType
    NSPredicate *sortPredicate = nil;
    NSString *sectionKeyPath = nil;
    if(!self.currentSortType) {
        self.currentSortType = MovieSortTypeAll;
    }
    if(self.currentSortType == MovieSortTypeUnwatched) {
        sortPredicate = [NSPredicate predicateWithFormat:@"watchedOn == nil"];
    } else if(self.currentSortType == MovieSortTypeUnrated) {
        sortPredicate = [NSPredicate predicateWithFormat:@"rating == 0"];
    } else if (self.currentSortType == MovieSortTypeAll && searchString == nil) {
        sectionKeyPath = @"rating";
    }
    
    // Search String
    NSMutableArray *predicateArray = [NSMutableArray array];
    if(searchString.length) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString]];
        if(sortPredicate) {
            sortPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:sortPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        } else {
            sortPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }

    if(sortPredicate) {
        [fetchRequest setPredicate:sortPredicate];
    }
    
    // Sorting
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    if(self.currentSortType == MovieSortTypeAll) {
        [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO]];
    }
    [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSDictionary *entityProperties = [[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]] propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:
                                        [entityProperties objectForKey:@"title"],
                                        [entityProperties objectForKey:@"rating"],
                                        [entityProperties objectForKey:@"watchedOn"],
                                        [entityProperties objectForKey:@"posterPath"],
                                        [entityProperties objectForKey:@"releaseDate"],
                                        nil]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                   managedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]
                                                                     sectionNameKeyPath:sectionKeyPath
                                                                              cacheName:nil];

    aFetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        ErrorLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    DebugLog("");
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil)
    {
        return _searchFetchedResultsController;
    }
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return _searchFetchedResultsController;
}


- (void)loadMoviesWithSortType:(MovieSortType)sortType
{
    self.currentSortType = sortType;

    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)aTableView
{
    return aTableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (UITableView *)tableViewForResultsController:(NSFetchedResultsController *)aController
{
    return aController == self.fetchedResultsController ? self.tableView : self.searchController.searchResultsTableView;
}

- (BOOL)isOnlineSearchSectionInTableView:(UITableView *)aTableView currentSection:(NSInteger)section
{
    NSFetchedResultsController *currentController = [self fetchedResultsControllerForTableView:aTableView];
    if([currentController isEqual:self.searchFetchedResultsController] && section == [[currentController sections] count]) {
        return true;
    }
    return false;
}

- (MovieCellType)cellTypeForTableView:(UITableView*)aTableView indexPath:(NSIndexPath*)indexPath
{
    MovieCellType cellType;
    if([self isOnlineSearchSectionInTableView:aTableView currentSection:indexPath.section]) {
        if(indexPath.row >= self.searchResults.count) {
            cellType = MovieCellTypeLoading;
        } else {
            cellType = MovieCellTypeOnline;
        }
    } else {
        cellType = MovieCellTypeDefault;
    }
    return cellType;
}

- (NSFetchedResultsController *)activeFetchedResultsController
{
    if(_searchController.active) {
        return self.searchFetchedResultsController;
    }
    return self.fetchedResultsController;
}

- (UITableView *)activeTableView
{
    if(_searchController.active) {
        return _searchController.searchResultsTableView;
    }
    return self.tableView;
}

- (void)contextDidSave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
        [mainContext mergeChangesFromContextDidSaveNotification:notification];
        DebugLog("");
        //[self loadMoviesWithSortType:self.currentSortType];
        //[self.tableView reloadData];
        //[self.searchController.searchResultsTableView reloadData];
    });
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (IBAction)filterControlDidChangeValue:(id)sender
{
    NSInteger selectedIndex = [(UISegmentedControl *)sender selectedSegmentIndex] + 1;
    
    if(selectedIndex ==MovieSortTypeAll) {
        [self loadMoviesWithSortType:MovieSortTypeAll];
    } else if (selectedIndex == MovieSortTypeUnrated) {
        [self loadMoviesWithSortType:MovieSortTypeUnrated];
    } else {
        [self loadMoviesWithSortType:MovieSortTypeUnwatched];
    }
    
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchFetchedResultsController = nil;
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {

    // TableView Styles
    _searchController.searchResultsTableView.backgroundColor = HEXColor(DEFAULT_COLOR_BG);
    _searchController.searchResultsTableView.separatorColor = HEXColor(0x1C1C1C);
    
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    _searchController.searchResultsTableView.tableFooterView = emptyTable;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching | UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    totalPages = 1;
    currentPage = 0;
    [_searchOperations cancelAllOperations];
    [self.searchResults removeAllObjects];
}

- (void)startSearch
{
    NSString *searchText = self.searchBar.text;
    [self startSearchWithQuery:searchText];
}

- (void)startSearchWithQuery:(NSString*)query
{
    isLoading = YES;
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithSearchString:query atPage:currentPage completion:^(NSDictionary *results) {
        
        isLoading = NO;
        isError = NO;
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult instanceFromDictionary:movie];
            
            BOOL isAdded = [Movie movieWithServerIDExists:[aResult.searchResultId integerValue] usingManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
            if(!isAdded) {
                [self.searchResults addObject:aResult];
            }
        }
        [_searchController.searchResultsTableView reloadData];
    
    } failure:^(NSError *error) {
        DebugLog("%@", [error localizedDescription]);
        isLoading = NO;
        isError = YES;
    }];
    [_searchOperations addOperation:operation];
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase:(SearchResult*)aSearchResult
{
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    AFJSONRequestOperation *operation = [bridge saveSearchResultAsMovie:aSearchResult completion:^(Movie *movie) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchResults removeObject:aSearchResult];
            self.searchFetchedResultsController = nil;
            [[self activeTableView] reloadData];
        });
    } failure:^(NSError *error) {
        DebugLog("%@", [error localizedDescription]);
    }];
    [operation start];
}


@end

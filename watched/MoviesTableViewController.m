//
//  MoviesTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 09.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
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
#import "MJLoadingAccessoryControl.h"
#import "MJReloadAccessoryControl.h"
#import "UIColor+Additions.h"

#define kSectionHeaderHeight 24.0f

#define kMovieTableDefaultCell @"kMovieTableDefaultCell"




@interface MoviesTableViewController ()
@end




@implementation MoviesTableViewController


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
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"SEARCHBAR_PLACEHOLDER", nil);

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    [headerView addSubview:_searchBar];
    self.tableView.tableHeaderView = headerView;
    
    
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _searchController.delegate = self;
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsTableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:[[MoviesDataModel sharedDataModel] mainContext]];
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
    NSInteger sectionCount = [[currentController sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:aTableView] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    // without headers
    if(_currentSortType != MovieSortTypeAll) return nil;
    NSString *star = [[[[self fetchedResultsControllerForTableView:aTableView] sections] objectAtIndex:section] name];
    if([star isEqualToString:@"0"]) star = NSLocalizedString(@"HEADER_TITLE_ZERORATING", nil);
    return star;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoviesTableViewCell *cell = [[MoviesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMovieTableDefaultCell];
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:aTableView] configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)aFetchedResultsController configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    MoviesTableViewCell *cell = (MoviesTableViewCell*)aCell;
    
    Movie *movie = [aFetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = movie.title;
    [cell.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.backgroundColor = [UIColor whiteColor];
    // get year
    [cell setYear:movie.releaseDate];
    [cell setCoverImage:movie.posterThumbnail];
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
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, 320, kSectionHeaderHeight)];
    backgroundView.backgroundColor = [UIColor colorWithHexString:@"F0F0F0"];
    
    if(rating > 0) {
        UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 6.0f, 20.0f*rating, 13.0f)];
        [starView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"divider-star"]]];
        [backgroundView addSubview:starView];
    } else {
        UILabel *unratedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 320.0f, kSectionHeaderHeight-1)];
        unratedLabel.backgroundColor = [UIColor clearColor];
        unratedLabel.textColor = [UIColor grayColor];
        unratedLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:12.0f];
        unratedLabel.text = sectionTitle;
        [backgroundView addSubview:unratedLabel];
    }
    
    [headerView addSubview:backgroundView];
    return headerView;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (Movie*)movieForTableView:(UITableView*)aTableView atIndexPath:(NSIndexPath*)aIndexPath
{
    return [[self activeFetchedResultsController] objectAtIndexPath:aIndexPath];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Movie *aMovie = [self movieForTableView:aTableView atIndexPath:indexPath];
    [self performSegueWithIdentifier:@"MovieDetailSegue" sender:aMovie];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Movie *aMovie = nil;
        aMovie = [self movieForTableView:aTableView atIndexPath:indexPath];
        [self deleteMovie:aMovie];
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
        [aTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    } else if(type == NSFetchedResultsChangeInsert) {
        [aTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(type == NSFetchedResultsChangeMove) {
        if (newIndexPath == nil) return;
        [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [aTableView insertRowsAtIndexPaths: [NSArray arrayWithObject:newIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    } else if(type == NSFetchedResultsChangeUpdate) {
        [aTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        // Why did i implement this? Well... leave it until i know
        [aTableView reloadSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    // this method is invoced by the main table view and automatically deletes sections
    if(type == NSFetchedResultsChangeDelete) {
        [[self tableViewForResultsController:controller] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if(type == NSFetchedResultsChangeInsert) {
        [[self tableViewForResultsController:controller] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieDetailSegue"] && [sender isKindOfClass:[Movie class]]) {
        MovieDetailViewController *detailViewController = (MovieDetailViewController*)segue.destinationViewController;
        detailViewController.movie = (Movie*)sender;
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
            sortPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:sortPredicate, [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray], nil]];
        } else {
            sortPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
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
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)aTableView
{
    return aTableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (UITableView *)tableViewForResultsController:(NSFetchedResultsController *)aController
{
    return aController == self.fetchedResultsController ? self.tableView : self.searchController.searchResultsTableView;
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
    });
}

- (void)deleteMovie:(Movie*)aMovie
{
    NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
    NSError *error;
    [mainContext deleteObject:aMovie];
    [mainContext save:&error];
    
    if(error) {
        ErrorLog("%@", [error localizedDescription]);
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
//    [emptyTable setBackgroundColor:[UIColor clearColor]];
    _searchController.searchResultsTableView.tableFooterView = emptyTable;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching | UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}



@end

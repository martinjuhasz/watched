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


const int kMovieDisplayCellTitleLabel = 100;
const int kMovieDisplayCellYearLabel = 101;
const int kMovieDisplayCellImageView = 200;


@interface MoviesTableViewController ()
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
- (void)loadMoviesWithSortType:(MovieSortType)sortType;
@end




@implementation MoviesTableViewController

@synthesize tableView;
@synthesize fetchedResultsController;
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
    
    // Add Button
    UIImage *addButtonBgImage = [[UIImage imageNamed:@"mv_addbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 8, 26, 8)];
    [self.addButton setBackgroundImage:addButtonBgImage forState:UIControlStateNormal];
    [self.addButton setTitleColor:HEXColor(0xFFFFFF) forState:UIControlStateNormal];
    [self.addButton setTitleShadowColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f] forState:UIControlStateNormal];
    [[self.addButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    self.addButtonBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mv_bg_add.png"]];
    [self.addButton setTitle:NSLocalizedString(@"BUTTON_ADDMOVIE_TITLE", nil) forState:UIControlStateNormal];
    
    // Segmented Control
    [self.sortControl setTitle:NSLocalizedString(@"CONTROL_SORTMOVIES_TITLE_ALL", nil) forSegmentAtIndex:0];
    [self.sortControl setTitle:NSLocalizedString(@"CONTROL_SORTMOVIES_TITLE_UNWATCHED", nil) forSegmentAtIndex:1];
    [self.sortControl setTitle:NSLocalizedString(@"CONTROL_SORTMOVIES_TITLE_UNRATED", nil) forSegmentAtIndex:2];
    
    // load Data
    [self loadMoviesWithSortType:MovieSortTypeAll];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoviesTableCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMovieDisplayCellTitleLabel];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:kMovieDisplayCellYearLabel];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kMovieDisplayCellImageView];
    
    
    Movie *movie = [fetchedResultsController objectAtIndexPath:indexPath];
    
    titleLabel.text = movie.title;
    yearLabel.text = [movie.releaseDate description];
    coverImageView.image = movie.posterThumbnail;
    //coverImageView.image = [UIima];
    
    // Retrieve the image from the database on a background queue
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_async(queue, ^{
//        UIImage *image = movie.poster;
//        XLog("%@", NSStringFromCGSize(image.size));
//        // use an index path to get at the cell we want to use because
//        // the original may be reused by the OS.
//        UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
//        
//        // check to see if the cell is visible
//        if ([[self.tableView visibleCells] containsObject:theCell]){
//            // put the image into the cell's imageView on the main queue
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIImageView *newCoverImageView = (UIImageView *)[theCell viewWithTag:kMovieDisplayCellImageView];
//                newCoverImageView.image = image;
//                [theCell setNeedsLayout];
//            });
//        }
//    });
    
    
    return cell;
}





////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		Movie *aMovie = nil;
        NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
		aMovie = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSError *error;
        
		[mainContext deleteObject:aMovie];
		[mainContext save:&error];
        if(error) {
            XLog("%@", [error localizedDescription]);
        }
    }
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieDetailSegue"]) {
        MovieDetailViewController *detailViewController = (MovieDetailViewController*)segue.destinationViewController;
        detailViewController.movie = [fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CoreData Handling

- (void)loadMoviesWithSortType:(MovieSortType)sortType
{
    self.currentSortType = sortType;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Movie entityName]];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"title", nil]];
    [fetchRequest setFetchBatchSize:40];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    // Filter by SortType
    NSPredicate *sortPredicate = nil;
    if(sortType == MovieSortTypeUnwatched) {
        sortPredicate = [NSPredicate predicateWithFormat:@"watchedOn == nil"];
    } else if(sortType == MovieSortTypeUnrated) {
        sortPredicate = [NSPredicate predicateWithFormat:@"rating == 0"];
    }
    if(sortPredicate) {
        [fetchRequest setPredicate:sortPredicate];
    }
    
    // Sorting
    NSSortDescriptor *movieSortDescriptor = nil;
    if(sortType == MovieSortTypeAll) {
        movieSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"rating" ascending:NO];
    } else {
        movieSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    }
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:movieSortDescriptor]];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                   managedObjectContext:[[MoviesDataModel sharedDataModel] mainContext] 
                                                                     sectionNameKeyPath:nil 
                                                                              cacheName:nil];
    
    NSDictionary *entityProperties = [[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]] propertiesByName];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:
                                        [entityProperties objectForKey:@"title"],
                                        [entityProperties objectForKey:@"rating"],
                                        [entityProperties objectForKey:@"watchedOn"],
                                        [entityProperties objectForKey:@"posterPath"],
                                        [entityProperties objectForKey:@"releaseDate"],
                                        nil]];
    
    [fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

- (void)contextDidSave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
        [mainContext mergeChangesFromContextDidSaveNotification:notification];
        
        [self loadMoviesWithSortType:self.currentSortType];
        [self.tableView reloadData];
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




@end

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


const int kMovieDisplayCellTitleLabel = 100;
const int kMovieDisplayCellYearLabel = 101;
const int kMovieDisplayCellImageView = 200;


@interface MoviesTableViewController ()
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
- (void)loadMovies;
@end




@implementation MoviesTableViewController

@synthesize tableView;
@synthesize fetchedResultsController;


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
    [self loadMovies];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:nil];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    
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
    coverImageView.image = movie.poster;
    
    return cell;
}





////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82.0f;
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

- (void)loadMovies
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Movie entityName]];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"title", nil]];
    [fetchRequest setFetchBatchSize:40];
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[MoviesDataModel sharedDataModel] mainContext] sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch:nil];
}

- (void)contextDidSave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *mainContext = [[MoviesDataModel sharedDataModel] mainContext];
        [mainContext mergeChangesFromContextDidSaveNotification:notification];
        
        [self loadMovies];
        [self.tableView reloadData];
    });
}





@end

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


const int kMovieDisplayCellTitleLabel = 100;
const int kMovieDisplayCellYearLabel = 101;
const int kMovieDisplayCellImageView = 200;

#define kSectionHeaderHeight 24.0f

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
    
    // appearance
    UIView *tableCellBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 79.0f)];
    tableCellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table.png"]];
    UIView *tableCellBackgroundViewSelected = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 79.0f)];
    tableCellBackgroundViewSelected.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table_active.png"]];
//    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"g_table-accessory.png"]];
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    
    [cell setBackgroundView:tableCellBackgroundView];
    [cell setSelectedBackgroundView:tableCellBackgroundViewSelected];
    [cell setAccessoryView:accessoryView];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMovieDisplayCellTitleLabel];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:kMovieDisplayCellYearLabel];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kMovieDisplayCellImageView];
    
    
    Movie *movie = [fetchedResultsController objectAtIndexPath:indexPath];
    
    // get year
    NSUInteger componentFlags = NSYearCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:movie.releaseDate];
    NSInteger year = [components year];
    
    titleLabel.text = movie.title;
    [titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    CGRect yearLabelRect = yearLabel.frame;
    yearLabelRect.origin.y = titleLabel.bottom;
    yearLabel.frame = yearLabelRect;
    yearLabel.text = [NSString stringWithFormat:@"%d", year];
    coverImageView.image = movie.posterThumbnail;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(currentSortType != MovieSortTypeAll) return nil;
    NSString *star = [[[fetchedResultsController sections] objectAtIndex:section] name];
    if([star isEqualToString:@"0"]) star = NSLocalizedString(@"HEADER_TITLE_ZERORATING", nil);
    return star;
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
        unratedLabel.text = NSLocalizedString(@"HEADER_TITLE_ZERORATING", nil);
        [backgroundView addSubview:unratedLabel];
    }
    
    [headerView addSubview:backgroundView];
    return headerView;
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
    return 78.0f;
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
    NSString *sectionKeyPath = nil;
    if(sortType == MovieSortTypeUnwatched) {
        sortPredicate = [NSPredicate predicateWithFormat:@"watchedOn == nil"];
    } else if(sortType == MovieSortTypeUnrated) {
        sortPredicate = [NSPredicate predicateWithFormat:@"rating == 0"];
    } else if (sortType == MovieSortTypeAll) {
        sectionKeyPath = @"rating";
    }
    
    if(sortPredicate) {
        [fetchRequest setPredicate:sortPredicate];
    }
    
    // Sorting
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    if(sortType == MovieSortTypeAll) {
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
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                   managedObjectContext:[[MoviesDataModel sharedDataModel] mainContext] 
                                                                     sectionNameKeyPath:sectionKeyPath 
                                                                              cacheName:nil];
    
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

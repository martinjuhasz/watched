//
//  SettingsTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "MoviesDataModel.h"
#import "Movie.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

@synthesize settings;
@synthesize movieCount;
@synthesize averageRating;

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"TITLE_SETTINGS", nil);
    
    [self loadStatistics];
    
    self.settings = [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_VERSION", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_MOVIECOUNT", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_AVERAGERATING", nil) forKey:@"name"],
                  nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_RESET", nil) forKey:@"name"],
                      nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_ABOUT", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_CONTACT", nil) forKey:@"name"],
                      nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:@"Feedback" forKey:@"name"],
                      nil],
                 nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settings count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[settings objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = [[[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self configureCellForRowAtIndexPath:indexPath cell:cell];
    return cell;
}

- (void)configureCellForRowAtIndexPath:(NSIndexPath*)indexPath cell:(UITableViewCell*)aCell
{
    if(indexPath.section == 0) {
        [self configureCellForStatisticsAtIndexPath:indexPath cell:aCell]; 
    }
}

- (void)configureCellForStatisticsAtIndexPath:(NSIndexPath*)indexPath cell:(UITableViewCell*)aCell
{
    aCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0)
    {
        aCell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    else if(indexPath.row == 1)
    {
        aCell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [movieCount intValue]];
    }
    else if(indexPath.row == 2)
    {
        if([averageRating floatValue] > 0) aCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", [averageRating floatValue]];
    }
}

- (void)reloadStatisticCells
{
    NSIndexPath *movieCountPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *averageRatingPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:movieCountPath,averageRatingPath, nil] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"SETTINGS_HEADER_STATISTICS", nil);
    if(section == 1) return NSLocalizedString(@"SETTINGS_HEADER_SETTINGS", nil);
    if(section == 2) return NSLocalizedString(@"SETTINGS_HEADER_CONTACT", nil);
    if(section == 3) return NSLocalizedString(@"SETTINGS_HEADER_BETA", nil);
    return nil;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Statistics
    if(indexPath.section == 0) return;
    
    // Settings
    if(indexPath.section == 1) {
        if(indexPath.row == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_POP_RESET_TITLE", nil)
                                                            message:NSLocalizedString(@"SETTINGS_POP_RESET_CONTENT", nil)
                                                           delegate:self 
                                                  cancelButtonTitle:NSLocalizedString(@"SETTINGS_POP_RESET_CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"SETTINGS_POP_RESET_OK", nil), nil];
            [alert show];
        }
    }
    
    // Beta
    if(indexPath.section == 3) {
        if(indexPath.row == 0) {
            [TestFlight openFeedbackView];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (IBAction)doneButtonClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Statistics

- (void)loadStatistics
{
    // Core Data
    NSManagedObjectContext *managedObjectContext = [[MoviesDataModel sharedDataModel] mainContext];
    
    // Fetch Movies
    NSFetchRequest *movieRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[Movie entityName] inManagedObjectContext:managedObjectContext];
    [movieRequest setEntity:entity];
    NSDictionary *entityProperties = [entity propertiesByName];
    [movieRequest setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:@"rating"]]];
    NSArray *movies = [managedObjectContext executeFetchRequest:movieRequest error:nil];
    
    // Movie Count
    self.movieCount = [NSNumber numberWithInteger:[movies count]];
    
    // Average Rating
    float averageValue = 0.0f;
    NSUInteger ratedMovieCount = 0;
    for(Movie *movie in movies) {
        if([[movie rating] floatValue] > 0.0f) ratedMovieCount++;
        averageValue += [[movie rating] floatValue];
    }
    averageValue = averageValue / ratedMovieCount;
    self.averageRating = [NSNumber numberWithFloat:averageValue];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        NSManagedObjectContext *managedObjectContext = [[MoviesDataModel sharedDataModel] mainContext];
        
        NSFetchRequest *movieIDs = [[NSFetchRequest alloc] init];
        [movieIDs setEntity:[NSEntityDescription entityForName:[Movie entityName] inManagedObjectContext:managedObjectContext]];
        [movieIDs setIncludesPropertyValues:NO];
        
        NSError * error = nil;
        NSArray * allMovies = [managedObjectContext executeFetchRequest:movieIDs error:&error];
        
        for (Movie *movie in allMovies) {
            [managedObjectContext deleteObject:movie];
        }
        
        [managedObjectContext save:nil];
        
        [self loadStatistics];
        [self reloadStatisticCells];
    }
}

@end

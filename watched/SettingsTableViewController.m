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
#import "OnlineDatabaseBridge.h"
#import "MBProgressHUD.h"
#import "WatchedWebBrowser.h"
#import <MessageUI/MessageUI.h>

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>

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
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_MOVIECOUNT", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_AVERAGERATING", nil) forKey:@"name"],
                  nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_RESET", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_REFRESH", nil) forKey:@"name"],
                      nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_FEEDBACK", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_WEBSITE", nil) forKey:@"name"],
                       [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_TWITTER", nil) forKey:@"name"],
                      nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_ABOUT", nil) forKey:@"name"],
                      nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:@"Feedback" forKey:@"name"],
                      [NSDictionary dictionaryWithObject:@"Dummy Content" forKey:@"name"],
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
    return [self.settings count];
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
    aCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    // Accecory Type
    if(indexPath.section == 0 || indexPath.section == 1) {
        aCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        aCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(indexPath.section == 0) {
        [self configureCellForStatisticsAtIndexPath:indexPath cell:aCell];
        return;
    }
    
    if(indexPath.section == 3 && indexPath.row == 0) {
        aCell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        return;
    }
    
    aCell.detailTextLabel.text = @"";
}

- (void)configureCellForStatisticsAtIndexPath:(NSIndexPath*)indexPath cell:(UITableViewCell*)aCell
{
    aCell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0)
    {
        aCell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [movieCount intValue]];
    }
    else if(indexPath.row == 1)
    {
        if([averageRating floatValue] > 0) {
            aCell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f", [averageRating floatValue]];
        } else {
            aCell.detailTextLabel.text = NSLocalizedString(@"SETTINGS_RATING_NONE", nil);
        }
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
    if(section == 3) return nil;
    if(section == 4) return NSLocalizedString(@"SETTINGS_HEADER_BETA", nil);
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
        } else if (indexPath.row == 1) {
            [self refreshAllMovies];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if(indexPath.section == 2) {
        if(indexPath.row == 0) {
            // check if can send mail
            if(![MFMailComposeViewController canSendMail]) return;
            
            // Generate Mail Composer and View it
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            mailViewController.mailComposeDelegate = self;
            NSString *title = NSLocalizedString(@"SETTINGS_FEEDBACK_EMAILTITLE", nil);
            title = [NSString stringWithFormat:@"%@ %@", title, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            [mailViewController setSubject:title];
            [mailViewController setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"SETTINGS_FEEDBACK_EMAILTO", nil)]];
            [self.navigationController presentModalViewController:mailViewController animated:YES];

        }
        if(indexPath.row == 1) {
            NSURL *url = [NSURL URLWithString:@"http://martinjuhasz.de"];
            [self performSegueWithIdentifier:@"SettingsBrowserSegue" sender:url];
        }
        if (indexPath.row == 2) {
            NSURL *url = [NSURL URLWithString:@"https://twitter.com/watchedapp"];
            [self performSegueWithIdentifier:@"SettingsBrowserSegue" sender:url];
        }
    }
    
    if(indexPath.section == 3) {
        if(indexPath.row == 0) {
            [self performSegueWithIdentifier:@"SettingsAboutSegue" sender:nil];
        }
    }
    
    // Beta
    if(indexPath.section == 4) {
        if(indexPath.row == 0) {
            [TestFlight openFeedbackView];
        } else if (indexPath.row == 1) {
            [self loadDummyContent];
        }
    }
    
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSPredicate *ratingPredicate = [NSPredicate predicateWithFormat:@"rating > 0"];
    [movieRequest setPredicate:ratingPredicate];
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
    if([alertView.title isEqualToString:NSLocalizedString(@"SETTINGS_POP_RESET_TITLE", nil)]) {
        if(buttonIndex == 1) {
            [self removeAllMovies];
        }
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Settings Actions

- (void)removeAllMovies
{
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

- (void)refreshAllMovies
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Setup Core Data with extra Context for Background Process
        OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
        
        // Fetch Movies
        NSFetchRequest *movieRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:[Movie entityName] inManagedObjectContext:context];
        [movieRequest setEntity:entity];
        NSArray *movies = [context executeFetchRequest:movieRequest error:nil];
        
        // Error Handling
        __block NSError *error;
        dispatch_group_t group = dispatch_group_create();
        
        for (Movie *currentMovie in movies) {
            dispatch_group_enter(group);
            [bridge updateMovieMetadata:currentMovie inContext:context completion:^(Movie *returnedMovie) {
                dispatch_group_leave(group);
            } failure:^(NSError *anError) {
                error = anError;
                dispatch_group_leave(group);
            }];
        }
        
        // wait until everything is finished
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);
        
        if(!error) {
            [context save:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = NSLocalizedString(@"SETTINGS_META_REFRESHED", nil);
                hud.mode = MBProgressHUDModeText;
                [hud hide:YES afterDelay:2.0];
            });
        } else {
            XLog("%@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = [error localizedDescription];
                hud.mode = MBProgressHUDModeText;
                [hud hide:YES afterDelay:2.0];
            });
        }
    });
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BETA

- (void)loadDummyContent
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    hud.mode = MBProgressHUDModeDeterminate;
    
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    
    NSArray *movieIDS = [NSArray arrayWithObjects:
                         [NSNumber numberWithInt:1726],
                         [NSNumber numberWithInt:58595],
                         [NSNumber numberWithInt:41154],
                         [NSNumber numberWithInt:70981],
                         [NSNumber numberWithInt:59961],
                         [NSNumber numberWithInt:24428],
                         [NSNumber numberWithInt:10138],
                         [NSNumber numberWithInt:49527],
                         [NSNumber numberWithInt:557],
                         [NSNumber numberWithInt:1930],
                         [NSNumber numberWithInt:14160],
                         [NSNumber numberWithInt:15563],
                         [NSNumber numberWithInt:855],
                         [NSNumber numberWithInt:50918],
                         [NSNumber numberWithInt:7870],
                         [NSNumber numberWithInt:11135],
                         nil];
    __block NSInteger count = 0;
    
    for (NSNumber *currentMovie in movieIDS) {
        
        [bridge saveMovieForID:currentMovie completion:^(Movie *returnedMovie) {
            count++;
            
            if(count == movieIDS.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [self loadStatistics];
                    [self reloadStatisticCells];
                });
            }
            XLog("%d of %d", count, movieIDS.count);
        } failure:^(NSError *anError) {
            count++;
            if(count == movieIDS.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [self loadStatistics];
                    [self reloadStatisticCells];
                });
            }
            XLog("%d of %d", count, movieIDS.count);
        }];
    }
    
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue Parameters

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SettingsBrowserSegue"]) {
        if([sender isKindOfClass:[NSURL class]]) {
            WatchedWebBrowser *browser = (WatchedWebBrowser*)segue.destinationViewController;
            browser.url = sender;
        }
    }
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}


@end

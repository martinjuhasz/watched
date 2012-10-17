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
#import "WatchedWebBrowser.h"
#import <MessageUI/MessageUI.h>
#import "AFJSONRequestOperation.h"
#import "MJCustomTableViewCell.h"
#import "MJCustomAccessoryControl.h"
#import "BlockAlertView.h"
#import "UIViewController+MJPopupViewController.h"
#import "LoadingPopupViewController.h"

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation SettingsTableViewController

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"TITLE_SETTINGS", nil);
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = HEXColor(DEFAULT_COLOR_BG);
    self.tableView.backgroundView = backgroundView;
    
    
    [self loadStatistics];
    
    self.settings = [NSArray arrayWithObjects:
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
                      [NSDictionary dictionaryWithObject:@"Dummy Content" forKey:@"name"],
//                      [NSDictionary dictionaryWithObject:@"Toggle debugger" forKey:@"name"],
                      nil],
                 nil];
    
    
    [self addHeaderView];
    [self addFooterView];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(-1.0f,0,0,0)];
    
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
    return [[_settings objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsTableViewCellCustom";
    MJCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MJCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    [cell configureForTableView:tableView indexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[[_settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self configureCellForRowAtIndexPath:indexPath cell:cell];
    return cell;
}

- (void)configureCellForRowAtIndexPath:(NSIndexPath*)indexPath cell:(UITableViewCell*)aCell
{
    aCell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    // Accecory Type
    if(indexPath.section == 0) {
        aCell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
        [aCell setAccessoryView:accessoryView];
    }
    
    aCell.detailTextLabel.text = @"";
}

- (void)reloadStatisticCells
{
    if([_averageRating floatValue] > 0) {
        self.averageRatingLabel.text = [NSString stringWithFormat:@"%.1f", [_averageRating floatValue]];
    } else {
        self.averageRatingLabel.text = @"-";
    }
    self.movieCountLabel.text = [NSString stringWithFormat:@"%i / %i", [_movieVotedCount intValue], [_movieCount intValue]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"SETTINGS_HEADER_SETTINGS", nil);
    if(section == 1) return NSLocalizedString(@"SETTINGS_HEADER_CONTACT", nil);
    if(section == 2) return NSLocalizedString(@"SETTINGS_HEADER_BETA", nil);
    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 43.0f)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 10.0f, headerView.frame.size.width - 20.0f, 22.0f)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont boldSystemFontOfSize:17.0f];
	label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
	label.backgroundColor = [UIColor clearColor];
    
	[headerView addSubview:label];
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 43.0f;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43.0f;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Settings
    if(indexPath.section == 0) {
        if(indexPath.row == 0)
        {
            
            BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"SETTINGS_POP_RESET_TITLE", nil)
                                                           message:NSLocalizedString(@"SETTINGS_POP_RESET_CONTENT", nil)];
            
            [alert setCancelButtonWithTitle:NSLocalizedString(@"SETTINGS_POP_RESET_CANCEL", nil) block:nil];
            [alert setDestructiveButtonWithTitle:NSLocalizedString(@"SETTINGS_POP_RESET_OK", nil) block:^{
                [self removeAllMovies];
            }];
            [alert show];
            
        } else if (indexPath.row == 1) {
            [self refreshAllMovies];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if(indexPath.section == 1) {
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
            NSURL *url = [NSURL URLWithString:@"http://watchedforios.com"];
            [self performSegueWithIdentifier:@"SettingsBrowserSegue" sender:url];
        }
        if (indexPath.row == 2) {
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=watchedapp"]];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            } else {
                NSURL *url = [NSURL URLWithString:@"https://twitter.com/watchedapp"];
                [self performSegueWithIdentifier:@"SettingsBrowserSegue" sender:url];
            }
        }
    }
    
    // Beta
    if(indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self loadDummyContent];
        } else if (indexPath.row == 1) {
            [self toggleDebugger];
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
    
    // rated
    NSPredicate *ratingPredicate = [NSPredicate predicateWithFormat:@"rating > 0"];
    NSArray *ratedMovies = [movies filteredArrayUsingPredicate:ratingPredicate];
    
    // Movie Count
    self.movieCount = [NSNumber numberWithInteger:[movies count]];
    self.movieVotedCount = [NSNumber numberWithInteger:[ratedMovies count]];
    
    // Average Rating
    float averageValue = 0.0f;
    NSUInteger ratedMovieCount = 0;
    for(Movie *movie in ratedMovies) {
        if([[movie rating] floatValue] > 0.0f) ratedMovieCount++;
        averageValue += [[movie rating] floatValue];
    }
    averageValue = averageValue / ratedMovieCount;
    self.averageRating = [NSNumber numberWithFloat:averageValue];
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
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    hud.mode = MBProgressHUDModeDeterminate;
//    hud.progress = 0.0f;

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _loadingController = nil;
    _loadingController = (LoadingPopupViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"LoadingMovieViewController"];
    [self presentPopupViewController:_loadingController animationType:PopupViewAnimationSlideBottomBottom];
    _loadingController.titleLabel.text = @"loading...";
    
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
        
        // queue all
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:2];
        [queue setSuspended:YES];
        
        // Error Handling
        __block NSError *error;
        dispatch_group_t group = dispatch_group_create();
        float total = movies.count;
        __block int current = 0;
        
        for (Movie *currentMovie in movies) {
            dispatch_group_enter(group);
            AFJSONRequestOperation *operation = [bridge updateMovieMetadata:currentMovie inContext:context completion:^(Movie *returnedMovie) {
                current++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *progress = [NSString stringWithFormat:@"%d / %.0f", current, total];
                    _loadingController.titleLabel.text = progress;
//                    hud.progress = current / total;
                });
                dispatch_group_leave(group);
            } failure:^(NSError *anError) {
                current++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *progress = [NSString stringWithFormat:@"%d / %.0f", current, total];
                    _loadingController.titleLabel.text = progress;
//                    hud.progress = current / total;
                });
                error = anError;
                dispatch_group_leave(group);
            }];
            [queue addOperation:operation];
        }
        [queue setSuspended:NO];
        
        // wait until everything is finished
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);
        
        if(!error) {
            [context save:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
//                hud.labelText = NSLocalizedString(@"SETTINGS_META_REFRESHED", nil);
//                hud.mode = MBProgressHUDModeText;
//                [hud hide:YES afterDelay:2.0];
                [self closeLoadingController];
            });
        } else {
            XLog("%@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
//                hud.labelText = [error localizedDescription];
//                hud.mode = MBProgressHUDModeText;
//                [hud hide:YES afterDelay:2.0];
                [self closeLoadingController];
            });
        }
    });
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BETA

- (void)toggleDebugger
{
#ifdef DEBUG
//    PDDebugger *debugger = [PDDebugger defaultInstance];
//    NSString *status;
//    if(![debugger isConnected]) {
//        // http debug
//        [debugger connectToURL:[NSURL URLWithString:@"ws://10.0.1.11:9000/device"]];
//        [debugger enableNetworkTrafficDebugging];
//        // TODO: Private API Call!
//        [debugger forwardAllNetworkTraffic];
//        
//        status = @"activated";
//        
//        // core data
//        [debugger enableCoreDataDebugging];
//        [debugger addManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext] withName:@"Main Context"];
//    } else {
//        [debugger removeManagedObjectContext:[[MoviesDataModel sharedDataModel] mainContext]];
//        [debugger disconnect];
//        status = @"disabled";
//    }
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Debugger"
//                                                    message:[NSString stringWithFormat:@"Debugger %@", status]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
#endif
}

- (void)loadDummyContent
{
//    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    hud.mode = MBProgressHUDModeDeterminate;
//    hud.progress = 0.0f;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    _loadingController = nil;
    _loadingController = (LoadingPopupViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"LoadingMovieViewController"];
    [self presentPopupViewController:_loadingController animationType:PopupViewAnimationSlideBottomBottom];
    _loadingController.titleLabel.text = @"loading...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:2];
        [queue setSuspended:YES];
        
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
                             [NSNumber numberWithInt:80321],
                             [NSNumber numberWithInt:57165],
                             [NSNumber numberWithInt:80585],
                             [NSNumber numberWithInt:49529],
                             [NSNumber numberWithInt:426],
                             [NSNumber numberWithInt:6282],
                             [NSNumber numberWithInt:13],
                             [NSNumber numberWithInt:105],
                             [NSNumber numberWithInt:22954],
                             [NSNumber numberWithInt:429],
                             [NSNumber numberWithInt:387],
                             [NSNumber numberWithInt:9533],
                             [NSNumber numberWithInt:50348],
                             [NSNumber numberWithInt:3034],
                             [NSNumber numberWithInt:603],
                             [NSNumber numberWithInt:243],
                             [NSNumber numberWithInt:525],
                             [NSNumber numberWithInt:812],
                             [NSNumber numberWithInt:7549],
                             [NSNumber numberWithInt:613],
                             [NSNumber numberWithInt:857],
                             [NSNumber numberWithInt:44639],
                             [NSNumber numberWithInt:13016],
                             [NSNumber numberWithInt:36419],
                             [NSNumber numberWithInt:238],
                             [NSNumber numberWithInt:10193],
                             nil];
        
        dispatch_group_t group = dispatch_group_create();
        
        float total = movieIDS.count; 
        __block int current = 0;
        
        for (NSNumber *currentMovie in movieIDS) {
            dispatch_group_enter(group);
            AFJSONRequestOperation *operation = [bridge saveMovieForID:currentMovie completion:^(Movie *returnedMovie) {
                current++;
                dispatch_async(dispatch_get_main_queue(), ^{
//                    hud.progress = current / total;
                    NSString *progress = [NSString stringWithFormat:@"%d / %.0f", current, total];
                    _loadingController.titleLabel.text = progress;
                });
                dispatch_group_leave(group);
            } failure:^(NSError *anError) {
                current++;
                dispatch_async(dispatch_get_main_queue(), ^{
//                    hud.progress = current / total;
                    NSString *progress = [NSString stringWithFormat:@"%d / %.0f", current, total];
                    _loadingController.titleLabel.text = progress;
                });
                XLog("%@",[anError localizedDescription]);
                dispatch_group_leave(group);
            }];
            [queue addOperation:operation];
            
        }
        [queue setSuspended:NO];
        
        // wait until everything is finished
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        dispatch_release(group);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hide:YES];
            [self closeLoadingController];
            [self loadStatistics];
            [self reloadStatisticCells];
        });
    });
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



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Header and Footer View

- (void)addHeaderView
{
    // Statistic View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 118.0f)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sv_bg_stats.png"]];
    
    UILabel *ratedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 70.0f, 141.0f, 13.0f)];
    UILabel *averageLabel = [[UILabel alloc] initWithFrame:CGRectMake(167.0f, 70.0f, 141.0f, 13.0f)];
    ratedLabel.text = NSLocalizedString(@"SETTINGS_MOVIECOUNT", nil);
    ratedLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    ratedLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.2f];
    ratedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    ratedLabel.textColor = HEXColor(0x666666);
    ratedLabel.textAlignment = UITextAlignmentCenter;
    ratedLabel.backgroundColor = [UIColor clearColor];
    averageLabel.text = NSLocalizedString(@"SETTINGS_AVERAGERATING", nil);
    averageLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    averageLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.2f];
    averageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    averageLabel.textColor = HEXColor(0x666666);
    averageLabel.textAlignment = UITextAlignmentCenter;
    averageLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:ratedLabel];
    [headerView addSubview:averageLabel];
    
    self.movieCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0f, 18.0f, 137.0f, 46.0f)];
    self.movieCountLabel.font = [UIFont boldSystemFontOfSize:37.0f];
    self.movieCountLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.2f];
    self.movieCountLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.movieCountLabel.textColor = HEXColor(0x4C4C4C);
    self.movieCountLabel.textAlignment = UITextAlignmentCenter;
    self.movieCountLabel.backgroundColor = [UIColor clearColor];
    
    self.averageRatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(169.0f, 18.0f, 137.0f, 46.0f)];
    self.averageRatingLabel.font = [UIFont boldSystemFontOfSize:37.0f];
    self.averageRatingLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.2f];
    self.averageRatingLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.averageRatingLabel.textColor = HEXColor(0x4C4C4C);
    self.averageRatingLabel.textAlignment = UITextAlignmentCenter;
    self.averageRatingLabel.backgroundColor = [UIColor clearColor];
    
    [self reloadStatisticCells];
    
    [headerView addSubview:self.movieCountLabel];
    [headerView addSubview:self.averageRatingLabel];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)addFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f, 320.0f, 52.0f)];
    footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sv_bg_footerview.png"]];
    
    UILabel *watchedLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 4.0f, 140.0f, 30.0f)];
    watchedLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    watchedLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    watchedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    watchedLabel.textColor = [UIColor whiteColor];
    watchedLabel.text = @"watched.";
    watchedLabel.backgroundColor = [UIColor clearColor];
    [footerView addSubview:watchedLabel];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0f, 19.0f, 140.0f, 30.0f)];
    versionLabel.font = [UIFont systemFontOfSize:10.0f];
    versionLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
    versionLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    versionLabel.textColor = HEXColor(0xCCCCCC);
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    versionLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"SETTINGS_VERSION", nil), versionString];
    versionLabel.backgroundColor = [UIColor clearColor];
    [footerView addSubview:versionLabel];
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton addTarget:self action:@selector(watchedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    actionButton.frame = footerView.frame;
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 72.0f)];
    wrapperView.backgroundColor = [UIColor clearColor];
    
    [wrapperView addSubview:footerView];
    [wrapperView addSubview:actionButton];
    
    self.tableView.tableFooterView = wrapperView;
}

- (IBAction)watchedButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"SettingsAboutSegue" sender:nil];
}


- (void)AddMovieControllerCancelButtonClicked:(LoadingPopupViewController *)loadingPopupViewController
{
    [self closeLoadingController];
}

- (void)closeLoadingController
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom completion:nil];
    _loadingController = nil;
}

@end

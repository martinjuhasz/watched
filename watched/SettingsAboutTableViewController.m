//
//  SettingsAboutTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 12.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "SettingsAboutTableViewController.h"
#import "WatchedLocalWebBrowser.h"
#import "MJCustomTableViewCell.h"
#import "MJCustomAccessoryControl.h"
#import "WatchedWebBrowser.h"

#define kCreatorImageView 64826
#define kCreatorNameLabel 64827

@interface SettingsAboutTableViewController ()

@end


@implementation SettingsAboutTableViewController

@synthesize settings;



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"SETTINGS_ABOUT_TITLE", nil);
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = HEXColor(DEFAULT_COLOR_BG);
    self.tableView.backgroundView = backgroundView;
    
    self.settings = [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:@"Martin Juhasz" forKey:@"name"],
                      [NSDictionary dictionaryWithObject:@"Marius Scheel" forKey:@"name"],
                      nil],
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"themoviedb.org", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"AFNetworking", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"GMGridView", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"TestFlight", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"DLStarRating", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"KSReachability", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"OBGradientView", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"BlockAlerts and ActionSheets", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"Crashlytics", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"UISS", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"UIResponder+KeyboardCache", nil) forKey:@"name"],
                      nil],
                     nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    UITableViewCell *cell;
    
    if(indexPath.section == 0) {
        cell = [self creatorCellForIndexPath:indexPath];
    } else {
        cell = [self defaultCellForIndexPath:indexPath];
    }
    
//    [cell configureForTableView:tableView indexPath:indexPath];
    
    return cell;
}

- (UITableViewCell*)defaultCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"SettingsTableViewCellCustom";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    [cell setAccessoryView:accessoryView];
    
    // Configure the cell...
    cell.textLabel.text = [[[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (UITableViewCell*)creatorCellForIndexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"AboutCreatorTableCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    [cell setAccessoryView:accessoryView];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:kCreatorImageView];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:kCreatorNameLabel];
    
    // Configure the cell...
    nameLabel.text = [[[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    if(indexPath.row == 0) {
        imageView.image = [UIImage imageNamed:@"av_thumbnail-martin.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"av_thumbnail-marius.png"];
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"SETTINGS_ABOUT_TITLE_DES-DEV", nil);
    if(section == 1) return NSLocalizedString(@"SETTINGS_ABOUT_VENDOR", nil);
    return nil;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 43.0f)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, 10.0f, headerView.frame.size.width - 20.0f, 22.0f)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont boldSystemFontOfSize:17.0f];
	label.shadowOffset = CGSizeMake(0.0f, -1.0f);
    label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.22f];
	label.backgroundColor = [UIColor clearColor];
    
	[headerView addSubview:label];
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 43.0f;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSURL *url;
    NSString *segueName;
    if (indexPath.section == 0) {
        segueName = @"SettingsBrowserSegue";
        if(indexPath.row == 0) {
            url = [NSURL URLWithString:@"http://martinjuhasz.de"];
        } else if(indexPath.row == 1) {
            url = [NSURL URLWithString:@"http://dribbble.com/rnarius"];
        }
    } else if (indexPath.section == 1) {
        segueName = @"SettingsLocalBrowserSegue";
        NSString *fileName = @"";
        switch (indexPath.row) {
            case 0:
                fileName = @"settings_tmdb";
                break;
            case 1:
                fileName = @"settings_afnetworking";
                break;
            case 2:
                fileName = @"settings_gmgridview";
                break;
            case 3:
                fileName = @"settings_testflight";
                break;
            case 4:
                fileName = @"settings_dlstarrating";
                break;
            case 5:
                fileName = @"settings_reachability";
                break;
            case 6:
                fileName = @"settings_obgradientview";
                break;
            case 7:
                fileName = @"settings_blockalerts";
                break;
            case 8:
                fileName = @"settings_crashlytics";
                break;
            case 9:
                fileName = @"settings_uiss";
                break;
            case 10:
                fileName = @"settings_keyboardcache";
                break;
        }
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"html"]];
    }
    [self performSegueWithIdentifier:segueName sender:url];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue Parameters

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SettingsLocalBrowserSegue"]) {
        if([sender isKindOfClass:[NSURL class]]) {
            UITableViewCell *aCell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
            WatchedLocalWebBrowser *browser = (WatchedLocalWebBrowser*)segue.destinationViewController;
            browser.url = sender;
            browser.title = aCell.textLabel.text;
        }
    } else if([segue.identifier isEqualToString:@"SettingsBrowserSegue"]) {
        if([sender isKindOfClass:[NSURL class]]) {
            WatchedWebBrowser *browser = (WatchedWebBrowser*)segue.destinationViewController;
            browser.url = sender;
        }
    }
}




@end

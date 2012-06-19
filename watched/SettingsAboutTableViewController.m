//
//  SettingsAboutTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 12.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsAboutTableViewController.h"
#import "WatchedLocalWebBrowser.h"

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
    
    self.settings = [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_ABOUT_VERSION", nil) forKey:@"name"],
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"SETTINGS_ABOUT_RELEASENOTES", nil) forKey:@"name"],
                      nil],
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
                      [NSDictionary dictionaryWithObject:NSLocalizedString(@"Reachability", nil) forKey:@"name"],
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
    static NSString *CellIdentifier = @"SettingsTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Seleectable
    if(indexPath.section == 0 && indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Accecory Type
    if(indexPath.section == 0 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    cell.textLabel.text = [[[settings objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return nil;
    if(section == 1) return NSLocalizedString(@"SETTINGS_ABOUT_TITLE_DES-DEV", nil);
    if(section == 2) return NSLocalizedString(@"SETTINGS_ABOUT_VENDOR", nil);
    return nil;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Statistics
    if(indexPath.section == 0 && indexPath.row == 0) return;
    
    NSURL *url;
    
    // Release Notes
    if(indexPath.section == 0 && indexPath.row == 1) {
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"settings_releasenotes" ofType:@"html"]];
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"settings_martin" ofType:@"html"]];
        } else if(indexPath.row == 1) {
            url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"settings_marius" ofType:@"html"]];
        }
    } else if (indexPath.section == 2) {
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
        }
        url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"html"]];
    }
    [self performSegueWithIdentifier:@"SettingsLocalBrowserSegue" sender:url];
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
    }
}




@end

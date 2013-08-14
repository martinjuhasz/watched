//
//  MovieCastsTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 31.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "MovieCastsTableViewController.h"
#import "OnlineMovieDatabase.h"
#import "UIImageView+AFNetworking.h"
#import "Movie.h"
#import "WatchedWebBrowser.h"
#import "MovieCastTableViewCell.h"
#import "MJCustomAccessoryControl.h"
#import "MJUCastDetailViewController.h"
#import "MJUCrew.h"
#import "MJUCast.h"

@interface MovieCastsTableViewController ()
@end

@implementation MovieCastsTableViewController

@synthesize movie;

const int kMovieCastCellCharacterLabel = 100;
const int kMovieCastCellNameLabel = 101;
const int kMovieCastCellProfileImageView = 200;


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"CAST_TITLE", nil);
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = HEXColor(DEFAULT_COLOR_BG);
    self.tableView.backgroundView = backgroundView;
    
    [self.movie getPersonsWithCompletion:^(NSArray *casts, NSArray *crews) {
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
    }];
    
    
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
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"CastDetailSegue" sender:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0) return self.movie.casts.count;
    return self.movie.crews.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJUPerson *currentPerson;
    if (indexPath.section == 0) {
        currentPerson = [self.movie.casts objectAtIndex:indexPath.row];
    } else {
        currentPerson = [self.movie.crews objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [self defaultCellAtIndexPath:indexPath];
    
    UILabel *characterLabel = (UILabel *)[cell viewWithTag:kMovieCastCellCharacterLabel];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:kMovieCastCellNameLabel];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kMovieCastCellProfileImageView];
    
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentPerson.profilePath imageType:ImageTypeProfile nearWidth:200.0f];
    [profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"cv_actor-placeholder.png"]];
    characterLabel.text = currentPerson.job;
    nameLabel.text = currentPerson.name;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"SECTION_HEADER_CAST", nil);
    }
    return NSLocalizedString(@"SECTION_HEADER_CREW", nil);
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, 43.0f)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, headerView.frame.size.width - 20.0f, 22.0f)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont boldSystemFontOfSize:17.0f];
	label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
	label.backgroundColor = [UIColor clearColor];
    
	[headerView addSubview:label];
	return headerView;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
    return 43.0f;
}

- (UITableViewCell*)defaultCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MovieCastsActorCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    [cell setAccessoryView:accessoryView];

    return cell;
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue Parameters

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if([segue.identifier isEqualToString:@"CastWebViewSegue"] && [sender isKindOfClass:[NSIndexPath class]]) {
//        
//        NSIndexPath *selectedPath = (NSIndexPath*)sender;
//        NSString *encodedName = @"";
//        
//        // get cast or crew
//        if(selectedPath.section == 0) {
//            Cast *currentCast = [self.movie.sortedCasts objectAtIndex:selectedPath.row];
//            encodedName = [currentCast.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        } else {
//            Crew *currentCrew = [self.movie.sortedCrews objectAtIndex:selectedPath.row];
//            encodedName = [currentCrew.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        }
//
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.imdb.com/find?q=%@", encodedName]];
//
//        WatchedWebBrowser *webBrowser = (WatchedWebBrowser*)segue.destinationViewController;
//        webBrowser.url = url;
//        
//    } else
    
    
    
    
    if([segue.identifier isEqualToString:@"CastDetailSegue"]) {
        
        NSIndexPath *selectedPath = (NSIndexPath*)sender;
        NSNumber *personID = nil;
        
        // get cast or crew
        MJUPerson *selectedPerson;
        if(selectedPath.section == 0) {
            selectedPerson = [self.movie.casts objectAtIndex:selectedPath.row];
        } else {
            selectedPerson = [self.movie.crews objectAtIndex:selectedPath.row];
        }
        
        ((MJUCastDetailViewController*)segue.destinationViewController).person = selectedPerson;
    }
}




@end

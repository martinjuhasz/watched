//
//  MovieCastsTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 31.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieCastsTableViewController.h"
#import "OnlineMovieDatabase.h"
#import "UIImageView+AFNetworking.h"
#import "Movie.h"
#import "Cast.h"
#import "Crew.h"
#import "WatchedWebBrowser.h"
#import "MovieCastTableViewCell.h"
#import "MJCustomAccessoryControl.h"

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
    [self performSegueWithIdentifier:@"CastWebViewSegue" sender:indexPath];
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
    if (indexPath.section == 0) {
        return [self castCellAtIndexPath:indexPath];
    }
    return [self crewCellAtIndexPath:indexPath];
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
    MovieCastTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MovieCastTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    [cell setAccessoryView:accessoryView];
    // Configure the cell...
    [cell configureForTableView:self.tableView indexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)castCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self defaultCellAtIndexPath:indexPath];
    
    UILabel *characterLabel = (UILabel *)[cell viewWithTag:kMovieCastCellCharacterLabel];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:kMovieCastCellNameLabel];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kMovieCastCellProfileImageView];
    
    Cast *currentCast = [self.movie.sortedCasts objectAtIndex:indexPath.row];
    
    if(currentCast.character && ![currentCast.character isEqualToString:@""]) {
        characterLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CAST_CHARACTER_PREFIX", nil), currentCast.character];
    } else {
        characterLabel.text = @"";
    }
    
    nameLabel.text = currentCast.name;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentCast.profilePath imageType:ImageTypeProfile nearWidth:200.0f];
    [profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"cv_actor-placeholder.png"]];
    
    return cell;
}

- (UITableViewCell *)crewCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self defaultCellAtIndexPath:indexPath];
    
    UILabel *characterLabel = (UILabel *)[cell viewWithTag:kMovieCastCellCharacterLabel];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:kMovieCastCellNameLabel];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kMovieCastCellProfileImageView];
    
    Crew *currentCrew = [self.movie.sortedCrews objectAtIndex:indexPath.row];
    
    if(currentCrew.job && ![currentCrew.job isEqualToString:@""]) {
        characterLabel.text = currentCrew.job;
    } else {
        characterLabel.text = @"";
    }
    
    nameLabel.text = currentCrew.name;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentCrew.profilePath imageType:ImageTypeProfile nearWidth:200.0f];
    [profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"cv_actor-placeholder.png"]];
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue Parameters

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CastWebViewSegue"] && [sender isKindOfClass:[NSIndexPath class]]) {
        
        NSIndexPath *selectedPath = (NSIndexPath*)sender;
        NSString *encodedName = @"";
        
        // get cast or crew
        if(selectedPath.section == 0) {
            Cast *currentCast = [self.movie.sortedCasts objectAtIndex:selectedPath.row];
            encodedName = [currentCast.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else {
            Crew *currentCrew = [self.movie.sortedCrews objectAtIndex:selectedPath.row];
            encodedName = [currentCrew.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.imdb.com/find?q=%@", encodedName]];

        WatchedWebBrowser *webBrowser = (WatchedWebBrowser*)segue.destinationViewController;
        webBrowser.url = url;
        
    }
}




@end

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

- (UITableViewCell *)castCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MovieCastsActorCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *characterLabel = (UILabel *)[cell viewWithTag:kMovieCastCellCharacterLabel];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:kMovieCastCellNameLabel];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kMovieCastCellProfileImageView];
    
    Cast *currentCast = [self.movie.sortedCasts objectAtIndex:indexPath.row];
    
    characterLabel.text = [NSString stringWithFormat:NSLocalizedString(@"CAST_CHARACTER_PREFIX", nil), currentCast.character];
    nameLabel.text = currentCast.name;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentCast.profilePath imageType:ImageTypeProfile nearWidth:200.0f];
    [profileImageView setImageWithURL:imageURL];
    
    return cell;
}

- (UITableViewCell *)crewCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MovieCastsActorCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *characterLabel = (UILabel *)[cell viewWithTag:kMovieCastCellCharacterLabel];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:kMovieCastCellNameLabel];
    UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:kMovieCastCellProfileImageView];
    
    Crew *currentCrew = [self.movie.sortedCrews objectAtIndex:indexPath.row];
    
    characterLabel.text = currentCrew.job;
    nameLabel.text = currentCrew.name;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentCrew.profilePath imageType:ImageTypeProfile nearWidth:200.0f];
    [profileImageView setImageWithURL:imageURL];
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue Parameters

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CastWebViewSegue"]) {
        
        NSIndexPath *selectedPath = [self.tableView indexPathForSelectedRow];
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

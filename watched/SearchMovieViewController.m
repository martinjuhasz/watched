//
//  SearchMovieViewController.m
//  watched
//
//  Created by Martin Juhasz on 25.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchMovieViewController.h"
#import "OnlineMovieDatabase.h"
#import "SearchResult.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "Movie.h"
#import "Cast.h"
#import "Crew.h"
#import "Trailer.h"
#import "MoviesDataModel.h"
#import "UISearchBar+Additions.h"
#import <CoreData/CoreData.h>
#import "AFHTTPRequestOperation.h"
#import "NSDictionary+ObjectForKeyOrNil.h"

@implementation SearchMovieViewController

@synthesize tableView;
@synthesize searchBar;
@synthesize searchResults;

const int kMovieSearchLoadingCellTag = 2000;
const int kMovieSearchCellTitleLabel = 100;
const int kMovieSearchCellYearLabel = 101;
const int kMovieSearchCellImageView = 200;


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar setCancelButtonActive];
    [self.searchBar becomeFirstResponder];
    
    currentPage = 1;
    self.searchResults = [NSMutableArray array];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // display extra loading cell if there are some results
    if(self.searchResults > 0 && totalPages > currentPage) {
        return self.searchResults.count + 1;
    }
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check to see if loading cell needs to be displayed
    if (indexPath.row < self.searchResults.count) {
        return [self resultCellAtIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == kMovieSearchLoadingCellTag) {
        currentPage++;
        [self startSearchWithQuery:searchQuery];
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchResult *result = [searchResults objectAtIndex:indexPath.row];
    [self saveMovieToDatabase:result];
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewCells

- (UITableViewCell *)resultCellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchMovieTableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kMovieSearchCellTitleLabel];
    UILabel *yearLabel = (UILabel *)[cell viewWithTag:kMovieSearchCellYearLabel];
    UIImageView *coverImageView = (UIImageView *)[cell viewWithTag:kMovieSearchCellImageView];
    
    SearchResult *currentMovie = [self.searchResults objectAtIndex:indexPath.row];
    
    titleLabel.text = currentMovie.title;
    yearLabel.text = currentMovie.releaseYear;
    coverImageView.image = nil;
    NSURL *imageURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:currentMovie.posterPath imageType:imageTypePoster nearWidth:70.0f*2];
    [coverImageView setImageWithURL:imageURL];

    return cell;
}

- (UITableViewCell *)loadingCell
{
    static NSString *CellIdentifier = @"SearchMovieLoadingTableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.tag = kMovieSearchLoadingCellTag;
    return cell;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UISearchBar + Cancel

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    searchQuery = aSearchBar.text;
    
    // Reset all the Values
    self.searchResults = nil;
    self.searchResults = [NSMutableArray array];
    currentPage = 1;
    totalPages = 0;
    [self.tableView reloadData];
    
    // Start Search
    [self startSearchWithQuery:searchQuery];
    [aSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching

- (void)startSearchWithQuery:(NSString*)query
{
    [[OnlineMovieDatabase sharedMovieDatabase] getMoviesWithSearchString:query atPage:currentPage completion:^(NSDictionary *results) {
        
        NSArray *movies = [results objectForKey:@"results"];
        totalPages = [[results objectForKey:@"total_pages"] intValue];
        
        for (NSDictionary *movie in movies) {
            SearchResult *aResult = [SearchResult instanceFromDictionary:movie];
            [self.searchResults addObject:aResult];
        }
        [self.tableView reloadData];
    }];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Adding a Movie

- (void)saveMovieToDatabase:(SearchResult*)result
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    
    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:result.searchResultId completion:^(NSDictionary *movieDict) {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            // Setup Core Data with extra Context for Background Process
            NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
            [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
            
            NSInteger serverId = [[movieDict objectForKey:@"id"] intValue];
            Movie *movie = [Movie movieWithServerId:serverId usingManagedObjectContext:context];
            
            if(movie == nil) {
                
                // dispatch it
                dispatch_group_t group = dispatch_group_create();
                
                // Movie
                movie = [Movie insertInManagedObjectContext:context];
                [movie updateAttributes:movieDict];
                
                // Backdrop
                NSString *backdropString = [movieDict objectForKey:@"backdrop_path"];
                NSURL *backdropURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:backdropString imageType:imageTypeBackdrop nearWidth:800.0f];
                if(backdropURL) {
                    dispatch_group_enter(group);
                    NSURLRequest *backdropRequest = [NSURLRequest requestWithURL:backdropURL];
                    AFHTTPRequestOperation *backdropOperation = [[AFHTTPRequestOperation alloc] initWithRequest:backdropRequest];
                    [backdropOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        if([responseObject isKindOfClass:[NSData class]]) {
                            movie.backdrop = [UIImage imageWithData:responseObject];
                            dispatch_group_leave(group);
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"%@", [error localizedDescription]);
                        dispatch_group_leave(group);
                    }];
                    [backdropOperation start];
                }
                
                
                // Poster
                NSString *posterString = [movieDict objectForKey:@"poster_path"];
                NSURL *posterURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:posterString imageType:imageTypeBackdrop nearWidth:400.0f];
                if(posterURL) {
                    dispatch_group_enter(group);
                    NSURLRequest *posterRequest = [NSURLRequest requestWithURL:posterURL];
                    AFHTTPRequestOperation *posterOperation = [[AFHTTPRequestOperation alloc] initWithRequest:posterRequest];
                    [posterOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        movie.poster = [UIImage imageWithData:responseObject];
                        dispatch_group_leave(group);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"%@", [error localizedDescription]);
                        dispatch_group_leave(group);
                    }];
                    [posterOperation start];
                }
                
                
                // Casts
                dispatch_group_enter(group);
                [[OnlineMovieDatabase sharedMovieDatabase] getMovieCastsForMovieID:[NSNumber numberWithInt:serverId] completion:^(NSDictionary *returnArray) {
                    
                    NSArray *casts = [returnArray objectForKeyOrNil:@"cast"];
                    NSArray *crew = [returnArray objectForKeyOrNil:@"crew"];
                    NSMutableSet *castsSet = [NSMutableSet set];
                    NSMutableSet *crewSet = [NSMutableSet set];
                    
                    for (NSDictionary *castDict in casts) {
                        Cast *newCast = [Cast insertInManagedObjectContext:context];
                        newCast.character = [castDict objectForKeyOrNil:@"character"];
                        newCast.castID = [NSNumber numberWithInt:[[castDict objectForKeyOrNil:@"id"] intValue]];
                        newCast.name = [castDict objectForKeyOrNil:@"name"];
                        newCast.order = [NSNumber numberWithInt:[[castDict objectForKeyOrNil:@"order"] intValue]];
                        newCast.profilePath = [castDict objectForKeyOrNil:@"profile_path"];
                        [castsSet addObject:newCast];
                    }
                    
                    for (NSDictionary *crewDict in crew) {
                        Crew *newCrew = [Crew insertInManagedObjectContext:context];
                        newCrew.crewID = [NSNumber numberWithInt:[[crewDict objectForKeyOrNil:@"id"] intValue]];
                        newCrew.name = [crewDict objectForKeyOrNil:@"name"];
                        newCrew.department = [crewDict objectForKeyOrNil:@"department"];
                        newCrew.job = [crewDict objectForKeyOrNil:@"job"];
                        newCrew.profilePath = [crewDict objectForKeyOrNil:@"profile_path"];
                        [crewSet addObject:newCrew];
                    }
                    
                    movie.casts = castsSet;
                    movie.crews = crewSet;
                    dispatch_group_leave(group);
                }];
                
                // Trailers
                dispatch_group_enter(group);
                [[OnlineMovieDatabase sharedMovieDatabase] getMovieTrailersForMovieID:[NSNumber numberWithInt:serverId] completion:^(NSDictionary *returnArray) {
                    
                    NSArray *quicktime = [returnArray objectForKeyOrNil:@"quicktime"];
                    NSArray *youtube = [returnArray objectForKeyOrNil:@"youtube"];
                    NSMutableSet *trailerSet = [NSMutableSet set];
                    
                    for (NSDictionary *qtTrailer in quicktime) {
                        Trailer *newTrailer = [Trailer insertInManagedObjectContext:context];
                        newTrailer.name = [qtTrailer objectForKeyOrNil:@"name"];
                        newTrailer.source = @"quicktime";
                        NSString *storedSize = nil;
                        for (NSDictionary *newTrailerSource in [qtTrailer objectForKeyOrNil:@"sources"]) {
                            
                            if(!storedSize || ([storedSize isEqualToString:@"480p"] && [[newTrailerSource objectForKeyOrNil:@"size"] isEqualToString:@"720p"])) {
                                newTrailer.url = [newTrailerSource objectForKeyOrNil:@"source"];
                                newTrailer.quality = [newTrailerSource objectForKeyOrNil:@"size"];
                            } else {
                                break;
                            }
                            storedSize = [newTrailerSource objectForKeyOrNil:@"size"];
                        }
                        [trailerSet addObject:newTrailer];
                    }
                    
                    for (NSDictionary *ytTrailer in youtube) {
                        Trailer *newTrailer = [Trailer insertInManagedObjectContext:context];
                        newTrailer.name = [ytTrailer objectForKeyOrNil:@"name"];
                        newTrailer.source = @"youtube";
                        newTrailer.quality = [ytTrailer objectForKeyOrNil:@"size"];
                        newTrailer.url = [ytTrailer objectForKeyOrNil:@"source"];
                        [trailerSet addObject:newTrailer];
                    }
                    
                    movie.trailers = trailerSet;
                    dispatch_group_leave(group);
                }];
                
                
                
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                dispatch_release(group);

                [context save:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Movie added";
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:1.0f];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"Movie already added";
                    hud.removeFromSuperViewOnHide = YES;
                    [hud hide:YES afterDelay:1.0f];
                });
            }
            
        });
    }];
        
}



@end

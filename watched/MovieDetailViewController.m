//
//  MovieDetailViewController.m
//  watched
//
//  Created by Martin Juhasz on 28.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "Movie.h"
#import "Cast.h"
#import "Crew.h"
#import "Trailer.h"
#import <CoreData/CoreData.h>
#import "MoviesDataModel.h"
#import "MovieDetailView.h"
#import "UIImageView+AFNetworking.h"
#import "OnlineMovieDatabase.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

@synthesize movie;
@synthesize detailView;



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
	// Do any additional setup after loading the view.
    
    // add detail view
    self.detailView = [[MovieDetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
    [self.view addSubview:self.detailView];
    self.detailView.ratingView.delegate = self;
    
    // set contents and enable buttone
    [self setContent];
    [self.detailView.websiteButton addTarget:self action:@selector(websiteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.trailerButton addTarget:self action:@selector(trailerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content Management

- (void)setContent
{
    self.title = self.movie.title;
    self.detailView.titleLabel.text = self.movie.title;
    self.detailView.backdropImageView.image = self.movie.backdrop;
    self.detailView.posterImageView.image = self.movie.poster;
    self.detailView.releaseDateLabel.text = self.movie.releaseDateFormatted;
    self.detailView.runtimeLabel.text = [self.movie.runtime stringValue];
    self.detailView.overviewLabel.text = self.movie.overview;
    self.detailView.ratingView.rating = [self.movie.rating floatValue];
    
    // actors
    NSSortDescriptor *actorSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortedCast = [[self.movie.casts allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:actorSort]];
    if(sortedCast.count >= 1) {
        Cast *cast1 = (Cast*)[sortedCast objectAtIndex:0];
        NSURL *cast1Url = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:cast1.profilePath imageType:imageTypeProfile nearWidth:400.0f];
        self.detailView.actor1Label.text = cast1.name;
        [self.detailView.actor1ImageView setImageWithURL:cast1Url];
    }
    if(sortedCast.count >= 2) {
        Cast *cast2 = (Cast*)[sortedCast objectAtIndex:1];
        NSURL *cast2Url = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:cast2.profilePath imageType:imageTypeProfile nearWidth:400.0f];
        self.detailView.actor2Label.text = cast2.name;
        [self.detailView.actor2ImageView setImageWithURL:cast2Url];
    }
    if(sortedCast.count >= 3) {
        Cast *cast3 = (Cast*)[sortedCast objectAtIndex:2];
        NSURL *cast3Url = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:cast3.profilePath imageType:imageTypeProfile nearWidth:400.0f];
        self.detailView.actor3Label.text = cast3.name;
        [self.detailView.actor3ImageView setImageWithURL:cast3Url];
    }
    
    
    
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (void)newRating:(DLStarRatingControl *)control :(float)newRating
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
        
        self.movie.rating = [NSNumber numberWithFloat:newRating];
        NSError *error;
        [context save:&error];
        if(error) {
            XLog("%@", [error localizedDescription]);
        }
        
    });
}

- (void)websiteButtonClicked:(id)sender
{
    if(self.movie.homepage) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.movie.homepage]];
    }
}

- (void)trailerButtonClicked:(id)sender
{
    if(!self.movie.bestTrailer) return;
    if([self.movie.bestTrailer.source isEqualToString:@"quicktime"]) {
        NSURL *quicktimeUrl = [NSURL URLWithString:self.movie.bestTrailer.url];
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:quicktimeUrl];
        [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayer];
    } else {
        NSURL *youtubeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", self.movie.bestTrailer.url]];
        [[UIApplication sharedApplication] openURL:youtubeUrl];
    }
}


@end

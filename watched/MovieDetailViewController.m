//
//  MovieDetailViewController.m
//  watched
//
//  Created by Martin Juhasz on 28.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "Movie.h"
#import <CoreData/CoreData.h>
#import "MoviesDataModel.h"


@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

@synthesize movie;
@synthesize mainScrollView;
@synthesize backdropImageView;
@synthesize posterImageView;
@synthesize titleLabel;
@synthesize releaseDateLabel;
@synthesize runtimeLabel;
@synthesize imdbRatingLabel;
@synthesize overviewLabel;
@synthesize ratingView;

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
    
    // rating view
    self.ratingView.delegate = self;
    
    [self setContent];

}

- (void)viewDidUnload
{
    [self setBackdropImageView:nil];
    [self setPosterImageView:nil];
    [self setTitleLabel:nil];
    [self setReleaseDateLabel:nil];
    [self setRuntimeLabel:nil];
    [self setImdbRatingLabel:nil];
    [self setOverviewLabel:nil];
    [self setRatingView:nil];
    [self setMainScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setContent
{
    
    self.title = self.movie.title;
    self.titleLabel.text = self.movie.title;
    self.backdropImageView.image = self.movie.backdrop;
    self.posterImageView.image = self.movie.poster;
    self.releaseDateLabel.text = [self.movie.releaseDate description];
    self.runtimeLabel.text = [self.movie.runtime stringValue];
    
    self.overviewLabel.text = self.movie.overview;
    self.overviewLabel.frame = CGRectMake(20.0f, 400.0f, self.overviewLabel.frame.size.width, 0);
    [self.overviewLabel sizeToFit];
    
    
    self.ratingView.rating = [self.movie.rating floatValue];
    
    [self arrangeContent];
    
}

- (void)arrangeContent
{
    self.mainScrollView.contentSize = CGSizeMake(320.0f, 2000.0f);
}

- (void)newRating:(DLStarRatingControl *)control :(float)newRating
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Setup Core Data with extra Context for Background Process
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
        
        self.movie.rating = [NSNumber numberWithFloat:newRating];
        [context save:nil];
        
    });
}

@end

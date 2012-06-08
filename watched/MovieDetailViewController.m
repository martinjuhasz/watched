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
#import "MovieCastsTableViewController.h"
#import "MovieNoteViewController.h"
#import <Twitter/Twitter.h>
#import "ThumbnailPickerViewController.h"

@interface MovieDetailViewController () {
    BOOL isLoadingImages;
}

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
    isLoadingImages = NO;
    
    // set contents and enable buttone
    [self setContent];
    
    [self.detailView.backdropButton addTarget:self action:@selector(posterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.posterButton addTarget:self action:@selector(posterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.watchedSwitch addTarget:self action:@selector(watchedSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    [self.detailView.noteButton addTarget:self action:@selector(noteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.trailerButton addTarget:self action:@selector(trailerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.websiteButton addTarget:self action:@selector(websiteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.castsButton addTarget:self action:@selector(castsButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        NSURL *cast1Url = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:cast1.profilePath imageType:ImageTypeProfile nearWidth:400.0f];
        self.detailView.actor1Label.text = cast1.name;
        [self.detailView.actor1ImageView setImageWithURL:cast1Url];
    }
    if(sortedCast.count >= 2) {
        Cast *cast2 = (Cast*)[sortedCast objectAtIndex:1];
        NSURL *cast2Url = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:cast2.profilePath imageType:ImageTypeProfile nearWidth:400.0f];
        self.detailView.actor2Label.text = cast2.name;
        [self.detailView.actor2ImageView setImageWithURL:cast2Url];
    }
    if(sortedCast.count >= 3) {
        Cast *cast3 = (Cast*)[sortedCast objectAtIndex:2];
        NSURL *cast3Url = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:cast3.profilePath imageType:ImageTypeProfile nearWidth:400.0f];
        self.detailView.actor3Label.text = cast3.name;
        [self.detailView.actor3ImageView setImageWithURL:cast3Url];
    }
    
    if(self.movie.watchedOn) self.detailView.watchedSwitch.on = YES;
    
    
    
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Segue Parameters

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"MovieCastSegue"]) {
        MovieCastsTableViewController *detailViewController = (MovieCastsTableViewController*)segue.destinationViewController;
        detailViewController.movie = self.movie;
    }
    if([segue.identifier isEqualToString:@"MovieNoteSegue"]) {
        MovieNoteViewController *detailViewController = (MovieNoteViewController*)segue.destinationViewController;
        detailViewController.movie = self.movie;
    }
    if([segue.identifier isEqualToString:@"ThumbnailPickerSegue"]) {
        NSDictionary *returnDict = (NSDictionary*)sender;
        NSArray *urlDict = [returnDict objectForKey:@"urls"];
        ImageType selectedImageType = [[returnDict objectForKey:@"imageType"] intValue];
        
        if(urlDict.count > 0) {
            ThumbnailPickerViewController *detailViewController = (ThumbnailPickerViewController*)segue.destinationViewController;
            detailViewController.imageURLs = urlDict;
            detailViewController.imageType = selectedImageType;
        }
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (IBAction)posterButtonClicked:(id)sender
{
    if(isLoadingImages) return;
    isLoadingImages = YES;
    
    ImageType selectedType = ((UIButton*)sender == self.detailView.posterButton) ? ImageTypePoster : ImageTypeBackdrop;
    [self.detailView toggleLoadingViewForPosterType:selectedType];
    
    [[OnlineMovieDatabase sharedMovieDatabase] getImagesForMovie:self.movie.movieID completion:^(NSDictionary *imageDict) {
        isLoadingImages = NO;
        [self.detailView toggleLoadingViewForPosterType:selectedType];
        if(selectedType == ImageTypePoster) {
            [self loadPickerForImageType:ImageTypePoster withResultDict:imageDict];
        } else {
            [self loadPickerForImageType:ImageTypeBackdrop withResultDict:imageDict];
        }
    } failure:^(NSError *error) {
        isLoadingImages = NO;
        [self.detailView toggleLoadingViewForPosterType:selectedType];
        XLog("%@", [error localizedDescription]);
    }];
}

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

- (IBAction)trailerButtonClicked:(id)sender
{
    if(!self.movie.bestTrailer) return;
    NSURL *videoURL = nil;
    
    if([self.movie.bestTrailer.source isEqualToString:@"quicktime"]) {
        videoURL = [NSURL URLWithString:self.movie.bestTrailer.url];
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayer];
    } else {
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",self.movie.bestTrailer.url]];
        [[UIApplication sharedApplication] openURL:videoURL];
    }
}

- (IBAction)castsButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"MovieCastSegue" sender:self];
}

- (IBAction)websiteButtonClicked:(id)sender
{
    if(self.movie.homepage) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.movie.homepage]];
    }
}

- (IBAction)noteButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"MovieNoteSegue" sender:self];
}

- (IBAction)watchedSwitchClicked:(id)sender {
    NSDate *watchedDate = nil;
    if(self.detailView.watchedSwitch.on) {
        watchedDate = [NSDate date];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
        
        self.movie.watchedOn = watchedDate;
        NSError *error;
        [context save:&error];
        if(error) {
            XLog("%@", [error localizedDescription]);
        }
        
    }); 
}

- (IBAction)shareButtonClicked:(id)sender
{
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] init];
    shareActionSheet.delegate = self;
    shareActionSheet.title = NSLocalizedString(@"SHARE_BUTTON_TITLE",nil);
    
    // E-Mail
    if([MFMailComposeViewController canSendMail])
        [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil)];
    
    // Twitter
    if([TWTweetComposeViewController canSendTweet]) {
        [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_TWITTER",nil)];
    }

    // Cancel Button
    [shareActionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_CANCEL",nil)];
    [shareActionSheet setCancelButtonIndex:[shareActionSheet numberOfButtons]-1];
    
    [shareActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Setup Core Data with extra Context for Background Process
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
        
        NSError *error;

        [context deleteObject:[context objectWithID:movie.objectID]];
        [context save:&error];
        if(error) {
            XLog("%@", [error localizedDescription]);
        }
        
    });
    [self.navigationController popViewControllerAnimated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:NSLocalizedString(@"SHARE_BUTTON_TWITTER",nil)]) {
        [self shareWithTwitter];
    } else if([title isEqualToString:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil)]) {
        [self shareWithEmail];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Sharing

- (void)shareWithTwitter
{
    if(![TWTweetComposeViewController canSendTweet]) return;
    
    NSString *text = [NSString stringWithFormat:@"I watched \"%@\" and rated it with %d of 5 Stars", self.movie.title, [self.movie.rating intValue]];
    
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    [twitter addImage:self.movie.poster];
    [twitter setInitialText:text];
    // TODO: Add Real URL
    //[twitter addURL:[NSURL URLWithString:@"http://martinjuhasz.de"]];
    
    [self presentModalViewController:twitter animated:YES];
}

- (void)shareWithEmail
{
    // check if can send mail
    if(![MFMailComposeViewController canSendMail]) return;
    
    // Get HTML String
    NSString *sharebymailPath = [[NSBundle mainBundle] pathForResource:@"sharebymail" ofType:@"html"];
    NSString *sharebymailString = [NSString stringWithContentsOfFile:sharebymailPath encoding:NSUTF8StringEncoding error:nil];
    NSString *imageURL = [[[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:self.movie.posterURL imageType:ImageTypeBackdrop nearWidth:260.0f] absoluteString];
 
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###IMAGE_URL###" withString:imageURL];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_TITLE###" withString:self.movie.title];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_DESCRIPTION###" withString:self.movie.overview];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_RATING###" withString:[NSString stringWithFormat:@"%d",[self.movie.rating intValue]]];
    
    // Generate Mail Composer and View it
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:self.movie.title];
    [mailViewController setMessageBody:sharebymailString isHTML:YES];
    
    [self presentModalViewController:mailViewController animated:YES];
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
#pragma mark Selecting Poster and Backdrop

- (void)loadPickerForImageType:(ImageType)aImageType withResultDict:(NSDictionary*)resultDict
{
    NSString *typeString = (aImageType == ImageTypePoster) ? @"posters" : @"backdrops";
    float imageWitdh = (aImageType == ImageTypePoster) ? 178.0f : 600.0f;
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    for (NSDictionary *aImageDict in [resultDict objectForKey:typeString]) {
        NSURL *aUrl = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:[aImageDict objectForKey:@"file_path"] 
                                                                               imageType:aImageType 
                                                                               nearWidth:imageWitdh];
        NSDictionary *aDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[aImageDict objectForKey:@"file_path"],aUrl, nil] 
                                                          forKeys:[NSArray arrayWithObjects:@"path",@"url", nil]];
        [imageURLs addObject:aDict];
    }
    
    NSDictionary *returnDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:aImageType], imageURLs, nil]  forKeys:[NSArray arrayWithObjects:@"imageType", @"urls", nil]];
    
    [self performSegueWithIdentifier:@"ThumbnailPickerSegue" sender:returnDict];
}






@end

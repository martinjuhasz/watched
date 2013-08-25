//
//  MovieDetailViewController.m
//  watched
//
//  Created by Martin Juhasz on 28.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "Movie.h"
#import <CoreData/CoreData.h>
#import "MoviesDataModel.h"
#import "MovieDetailView.h"
#import <Social/Social.h>
#import "OnlineMovieDatabase.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieCastsTableViewController.h"
#import "MovieNoteViewController.h"
#import "ThumbnailPickerViewController.h"
#import "OnlineDatabaseBridge.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchedWebBrowser.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "UIButton+Additions.h"
#import "MJCustomTableViewCell.h"
#import "MJCustomAccessoryControl.h"
#import "MJInternetConnection.h"
#import "SimilarMoviesTableViewController.h"
#import "MovieShareButtonView.h"
#import "MJUTrailer.h"
#import "MJUCast.h"
#import "MJUCrew.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+Additions.h"
#import <BlocksKit/BlocksKit.h>

#define kImageFadeDelay 0.0f

@interface MovieDetailViewController ()<ThumbnailPickerDelegate> {
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
        // Custom initializati
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // add detail view
    self.detailView = [[MovieDetailView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.detailView];
    
    self.detailView.ratingView.delegate = self;
    isLoadingImages = NO;
    
    // set contents and enable buttone
    [self setContent];

    [self setNavigationBarItems];
    [self.detailView.notesEditButton addTarget:self action:@selector(notesEditButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)viewWillAppear:(BOOL)animated
{
	NSIndexPath *selection = [self.detailView.metaTableView indexPathForSelectedRow];
	if (selection) [self.detailView.metaTableView deselectRowAtIndexPath:selection animated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content Management

- (void)setMovie:(Movie*)aMovie
{
    if(aMovie) {
        movie = aMovie;
        self.currentContext = [aMovie managedObjectContext];
    }
}

- (void)setNavigationBarItems
{
    NSMutableArray *buttonArray = [NSMutableArray array];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-share.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonClicked:)];
    [buttonArray addObject:shareButton];
    
    if(self.movie.movieState == MJUMovieStateAdded) {
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-more.png"] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonClicked:)];
        [buttonArray addObject:moreButton];
    }
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithArray:buttonArray];
}


- (void)setContent
{
    self.title = self.movie.title;
    self.detailView.metaTableView.dataSource = self;
    self.detailView.metaTableView.delegate = self;
    self.detailView.titleLabel.text = self.movie.title;
    self.detailView.ratingView.rating = [self.movie.rating floatValue];
    
    // Tagline
    self.detailView.overviewTitleLabel.text = self.movie.tagline;
    
    // Director
    self.detailView.directorLabel.text = @"-";
    
    // Overview
    if (self.movie.overview) {
        self.detailView.overviewLabel.text = self.movie.overview;
    } else {
        self.detailView.overviewLabel.text = NSLocalizedString(@"OVERVIEW_NO-CONTENT", nil);
    }
    
    // Release Date
    if (self.movie.releaseDate) {
        self.detailView.releaseLabel.text = self.movie.releaseDateFormatted;
    } else {
        self.detailView.releaseLabel.text = @"-";
    }
    
    // RUNTIME
    if([self.movie.runtime floatValue] > 0) {
        self.detailView.runtimeLabel.text = self.movie.runtimeFormatted;
    } else {
        self.detailView.runtimeLabel.text = @"-";
    }
    
    // Poster
    if (self.movie.poster) {
        self.detailView.posterImageView.image = self.movie.poster;
    } else if(self.movie.posterURL) {
        [self.detailView.posterImageView setImageWithURL:[NSURL URLWithString:self.movie.posterURL] placeholderImage:[UIImage imageNamed:@"cover-placeholder-detailview.png"]];
    }
    else {
        self.detailView.posterImageView.image = [UIImage imageNamed:@"cover-placeholder-detailview.png"];
    }
    
    // Backdrop
    if (self.movie.backdrop) {
         self.detailView.backdropImageView.image = self.movie.backdrop;
    } else if(self.movie.backdropURL) {
        [self.detailView.backdropImageView setImageWithURL:[NSURL URLWithString:self.movie.backdropURL] placeholderImage:nil];
    }
    
    // Notes
    if(self.movie.note) {
        self.detailView.notesLabel.text = self.movie.note;
    }
    
    
    // DEBUG
    if(self.movie.director) {
        self.detailView.directorLabel.text = self.movie.director;
    } else {
        self.detailView.directorLabel.text = @"-";
    }
    
    NSArray *actors = [NSKeyedUnarchiver unarchiveObjectWithData:self.movie.actors];
    if(actors.count > 0) {
        self.detailView.actor1Label.text = ((MJUCast*)[actors objectAtIndex:0]).name;
    } else {
        self.detailView.actor1Label.text = @"-";
    }
    if(actors.count > 1) {
        self.detailView.actor2Label.text = ((MJUCast*)[actors objectAtIndex:1]).name;
    }
    if(actors.count > 2) {
        self.detailView.actor3Label.text = ((MJUCast*)[actors objectAtIndex:2]).name;
    }
    if(actors.count > 3) {
        self.detailView.actor4Label.text = ((MJUCast*)[actors objectAtIndex:3]).name;
    }
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
        detailViewController.title = NSLocalizedString(@"NOTES_TITLE", nil);
    }
    if([segue.identifier isEqualToString:@"ThumbnailPickerSegue"]) {
        NSDictionary *returnDict = (NSDictionary*)sender;
        NSArray *urlDict = [returnDict objectForKey:@"urls"];
        ImageType selectedImageType = [[returnDict objectForKey:@"imageType"] intValue];
        
        if(urlDict.count > 0) {
            ThumbnailPickerViewController *detailViewController = (ThumbnailPickerViewController*)segue.destinationViewController;
            detailViewController.delegate = self;
            detailViewController.imageURLs = urlDict;
            detailViewController.imageType = selectedImageType;
        }
    }
    if([segue.identifier isEqualToString:@"SimilarMovieSegue"]) {
        SimilarMoviesTableViewController *detailViewController = (SimilarMoviesTableViewController*)segue.destinationViewController;
        detailViewController.movie = self.movie;
    }
    
    if([segue.identifier isEqualToString:@"DetailWebViewSegue"]) {
        if(![sender isKindOfClass:[NSURL class]]) return;
        NSURL *url = sender;
        WatchedWebBrowser *detailViewController = (WatchedWebBrowser*)segue.destinationViewController;
        detailViewController.url = url;
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Button Actions

- (void)posterButtonClicked:(ImageType)selectedType
{
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
        return;
    }
    
    if(isLoadingImages) return;
    isLoadingImages = YES;
    
    [self.detailView toggleLoadingViewForPosterType:selectedType];
    
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getImagesForMovie:self.movie.movieID completion:^(NSDictionary *imageDict) {
        
        // reset default state
        isLoadingImages = NO;
        [self.detailView toggleLoadingViewForPosterType:selectedType];
        
        // check if vc is still visible
        if (![self.navigationController.visibleViewController isKindOfClass:[MovieDetailViewController class]]) return;
        
        if(selectedType == ImageTypePoster) {
            [self loadPickerForImageType:ImageTypePoster withResultDict:imageDict];
        } else {
            [self loadPickerForImageType:ImageTypeBackdrop withResultDict:imageDict];
        }
    } failure:^(NSError *error) {
        isLoadingImages = NO;
        [self.detailView toggleLoadingViewForPosterType:selectedType];
        DebugLog("%@", [error localizedDescription]);
    }];
    [operation start];
}

- (IBAction)notesEditButtonClicked:(id)sender
{
    [self performSegueWithIdentifier:@"MovieNoteSegue" sender:self];
}

- (void)newRating:(DLStarRatingControl *)control :(float)newRating
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
        
        // retrieve Movie
        Movie *toSaveMovie = (Movie*)[context objectWithID:[self.movie objectID]];
        if(!toSaveMovie) return;
        
        toSaveMovie.rating = [NSNumber numberWithFloat:newRating];
        
        NSError *error;
        [context save:&error];
        if(error) {
            ErrorLog("%@", [error localizedDescription]);
        }
        
    });
}

- (void)trailerRowClicked
{
    [self.movie getBestTrailerWithCompletion:^(MJUTrailer *aTrailer) {
        if(!aTrailer) return;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:aTrailer.source]];
    } error:^(NSError *aError) {
        
    }];
    
    // default code
//    if(!self.movie.bestTrailer) return;
//    NSURL *videoURL = nil;
//    
//    if([self.movie.bestTrailer.source isEqualToString:@"quicktime"]) {
//        videoURL = [NSURL URLWithString:self.movie.bestTrailer.url];
//        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
//        [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayer];
//    } else {
//         videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@",self.movie.bestTrailer.url]];
//        [self performSegueWithIdentifier:@"DetailWebViewSegue" sender:videoURL];
//    }
    
    // opening web view
    
//    if(!self.movie.bestTrailer) return;
//    NSURL *videoURL = nil;
//    
//    if([self.movie.bestTrailer.source isEqualToString:@"quicktime"]) {
//        videoURL = [NSURL URLWithString:self.movie.bestTrailer.url];
//    } else {
//        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@",self.movie.bestTrailer.url]];
//    }
//    [[UIApplication sharedApplication] openURL:videoURL];
}

- (void)castsRowClicked
{
    [self performSegueWithIdentifier:@"MovieCastSegue" sender:self];
}

- (void)websiteRowClicked
{    
    if(self.movie.homepage) {
        NSURL *url = [NSURL URLWithString:self.movie.homepage];
        [self performSegueWithIdentifier:@"DetailWebViewSegue" sender:url];
    }
}

- (void)setWatchedStateToSeen:(BOOL)seen
{
    NSDate *watchedDate = nil;
    if(seen) {
        watchedDate = [NSDate date];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Setup Core Data with extra Context for Background Process
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
        
        // retrieve Movie
        Movie *toSaveMovie = (Movie*)[context objectWithID:[self.movie objectID]];
        if(!toSaveMovie) return;
        
        toSaveMovie.watchedOn = watchedDate;
        
        NSError *error;
        [context save:&error];
        if(error) {
            ErrorLog("%@", [error localizedDescription]);
        }
        
    });
}

- (IBAction)shareButtonClicked:(id)sender
{

    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    // E-Mail
    if([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil) handler:^{
            [self shareWithEmail];
        }];
    }
    
    // iMessage
    if([MFMessageComposeViewController canSendText]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_TEXT",nil) handler:^{
            [self shareWithMessage];
        }];
    }
    
    // Twitter
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_TWITTER",nil) handler:^{
        [self shareWithService:SLServiceTypeTwitter];
    }];
    
    // Facebook
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_FACEBOOK",nil) handler:^{
        [self shareWithService:SLServiceTypeFacebook];
    }];

    // Cancel Button
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_CANCEL",nil)];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];

    actionSheet.delegate = self;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    
}

- (IBAction)moreButtonClicked:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    if(self.movie.watchedOn) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"MORE_UNWATCHED",nil) handler:^{
            [self setWatchedStateToSeen:NO];
        }];
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"MORE_WACHED",nil) handler:^{
            [self setWatchedStateToSeen:YES];
        }];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"MORE_CHANGE_COVER",nil) handler:^{
        [self posterButtonClicked:ImageTypePoster];
    }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"MORE_CHANGE_BACKDROP",nil) handler:^{
        [self posterButtonClicked:ImageTypeBackdrop];
    }];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"MORE_REMOVE",nil) handler:^{
        [self deleteButtonClicked];
    }];
    
    // Cancel Button
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_CANCEL",nil)];
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons-1];
    
    actionSheet.delegate = self;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

- (void)deleteButtonClicked
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_TITLE", nil) message:NSLocalizedString(@"DETAIL_POP_DELETE_CONTENT", nil)];
    [alertView setCancelButtonWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_CANCEL", nil) handler:nil];
    [alertView addButtonWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_OK", nil) handler:^{
        [self deleteMovie];
    }];
    [alertView show];
//    BlockAlertView *alert = [BlockAlertView alertWithTitle:
//                                                   message:NSLocalizedString(@"DETAIL_POP_DELETE_CONTENT", nil)];
//    
//    [alert setCancelButtonWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_CANCEL", nil) block:nil];
//    [alert setDestructiveButtonWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_OK", nil) block:^{
//        [self deleteMovie];
//    }];
//    [alert show];
    
}

- (void)deleteMovie
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Setup Core Data with extra Context for Background Process
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
        
        NSError *error;
        
        [context deleteObject:[context objectWithID:movie.objectID]];
        [context save:&error];
        if(error) {
            ErrorLog("%@", [error localizedDescription]);
        }
        
    });
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)similarRowClicked
{
//    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
//        [[MJInternetConnection sharedInternetConnection] displayAlert];
//        NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
//        [self.detailView.metaTableView deselectRowAtIndexPath:path animated:YES];
//        return;
//    }
    
    [self performSegueWithIdentifier:@"SimilarMovieSegue" sender:nil];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Sharing

- (void)shareWithService:(NSString*)serviceType
{
    // check if accounts added
    if((serviceType == SLServiceTypeTwitter && ![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) ||
       (serviceType == SLServiceTypeFacebook && ![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])) {
        
        // Generate Texts
        NSString *accountName;
        if(serviceType == SLServiceTypeFacebook) {
            accountName = NSLocalizedString(@"SHARE_BUTTON_FACEBOOK", nil);
        } else {
            accountName = NSLocalizedString(@"SHARE_BUTTON_TWITTER", nil);
        }
        
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"DETAIL_POP_NOACCOUNT_TITLE", nil), accountName];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"DETAIL_POP_NOACCOUNT_CONTENT", nil), accountName, accountName];
        
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
//        [alert setCancelButtonWithTitle:NSLocalizedString(@"DETAIL_POP_NOACCOUNT_OK", nil) block:nil];
//        [alert show];
        
        return;
    }
    
    if([SLComposeViewController isAvailableForServiceType:serviceType]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        SLComposeViewControllerCompletionHandler completeBlock = ^(SLComposeViewControllerResult result){
            [composeViewController dismissViewControllerAnimated:YES completion:nil];
        };
        [composeViewController setCompletionHandler:completeBlock];
        
        NSString *text = [NSString string];
        if([self.movie.rating intValue] > 0) {
            text = [text stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"SHARE_TWITTER_TEXT_RATING", nil), [self.movie.rating intValue]]];
        }
        
        if(serviceType == SLServiceTypeTwitter) 
            text = [text stringByAppendingString:@" #watchedforios"];
        
        NSMutableString *titleText = [NSMutableString stringWithFormat:NSLocalizedString(@"SHARE_TWITTER_TEXT", nil), self.movie.title];
        NSString *completeText = [titleText stringByAppendingString:text];
        
        [composeViewController addImage:self.movie.poster];
        [composeViewController addURL:[NSURL URLWithString:@"http://watchedforios.com"]];
        
        BOOL textShortEnough = [composeViewController setInitialText:completeText];
        
        if(serviceType == SLServiceTypeTwitter) {
            if(!textShortEnough) {
                [titleText replaceOccurrencesOfString:@"\"" withString:@"...\"" options:NSCaseInsensitiveSearch range:NSMakeRange(titleText.length - 1, 1)];
            }
            
            while (!textShortEnough) {
                [titleText replaceCharactersInRange:NSMakeRange(titleText.length -5, 5) withString:@"...\""];
                completeText = [titleText stringByAppendingString:text];
                textShortEnough = [composeViewController setInitialText:completeText];
            }
        }
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (void)shareWithEmail
{
    // check if can send mail
    if(![MFMailComposeViewController canSendMail]) return;
    
    // Get HTML String
    NSString *sharebymailPath = [[NSBundle mainBundle] pathForResource:@"sharebymail" ofType:@"html"];
    NSString *sharebymailString = [NSString stringWithContentsOfFile:sharebymailPath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *imageURL;
    NSString *imageDisplay = @"inline-block";
    if(self.movie.posterURL) {
        imageURL = [[[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:self.movie.posterURL imageType:ImageTypeBackdrop nearWidth:260.0f] absoluteString];
    } else {
        imageURL = @"";
        imageDisplay = @"none";
    }
    
    NSString *mailTitle = (self.movie.title) ? self.movie.title : @"";
    NSString *mailOverview = (self.movie.overview) ? self.movie.overview : @"";
    NSString *mailID = (self.movie.movieID) ? [self.movie.movieID stringValue] : @"";
    NSString *mailTagline = (self.movie.tagline) ? self.movie.tagline : @"";
    NSString *mailNote = (self.movie.note) ? self.movie.note : @"";
    
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###IMAGE_URL###" withString:imageURL];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###IMAGE_DISPLAY###" withString:imageDisplay];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_NOTE###" withString:mailNote];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_TITLE###" withString:mailTitle];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_TAGLINE###" withString:mailTagline];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_DESCRIPTION###" withString:mailOverview];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_ID###" withString:mailID];
    
    
    int rating = [self.movie.rating intValue];
    NSString *ratingDisplay = @"block";
    if(rating > 0) {
        
        NSString *starEntidy = @"&#9733;";
        NSString *starEntidyUnrated = @"&#9734;";
        NSString *ratedString = [@"" stringByPaddingToLength:[starEntidy length]*rating withString:starEntidy startingAtIndex:0];
        NSString *unratedString = [@"" stringByPaddingToLength:[starEntidyUnrated length]*(5-rating) withString:starEntidyUnrated startingAtIndex:0];
        
        sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_RATING_RATED###" withString:ratedString];
        sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_RATING_UNRATED###" withString:unratedString];
    } else {
        sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_RATING_RATED###" withString:@""];
        sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_RATING_UNRATED###" withString:@""];
        ratingDisplay = @"none";
    }
    
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_RATING_DISPLAY###" withString:ratingDisplay];
    
    
    // Generate Mail Composer and View it
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:self.movie.title];
    [mailViewController setMessageBody:sharebymailString isHTML:YES];
    
    [self presentViewController:mailViewController animated:YES completion:nil];
}

- (void)shareWithMessage
{
    // check if can send mail
    if(![MFMessageComposeViewController canSendText]) return;
    
    NSString *text = [NSString string];
    if([self.movie.rating intValue] > 0) {
        text = [text stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"SHARE_TWITTER_TEXT_RATING", nil), [self.movie.rating intValue]]];
    }
    
    NSMutableString *titleText = [NSMutableString stringWithFormat:NSLocalizedString(@"SHARE_TWITTER_TEXT", nil), self.movie.title];
    NSString *completeText = [titleText stringByAppendingString:text];
    completeText = [completeText stringByAppendingString:[NSString stringWithFormat:@" watched://%@", [self.movie.movieID stringValue]]];
    
    // Generate Message Composer and View it
    MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
    messageViewController.messageComposeDelegate = self;
    messageViewController.body = completeText;
    
    [self presentViewController:messageViewController animated:YES completion:nil];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    if([[returnDict objectForKey:@"urls"] count] > 1) {
        [self performSegueWithIdentifier:@"ThumbnailPickerSegue" sender:returnDict];
    } else {
        
//        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"PICKER_POP_NOPOSTER_TITLE", nil)
//                                                       message:NSLocalizedString(@"PICKER_POP_NOPOSTER_CONTENT", nil)];
//        
//        [alert setCancelButtonWithTitle:NSLocalizedString(@"PICKER_POP_NOPOSTER_OK", nil) block:nil];
//        [alert show];
    }
    
}

- (void) thumbnailPicker:(ThumbnailPickerViewController*)aPicker didSelectImage:(NSString*)aImage forImageType:(ImageType)aImageType
{
    [self.navigationController popViewControllerAnimated:YES];
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    
    // Backdrop
    if(aImageType == ImageTypeBackdrop) {
        [bridge setBackdropWithImagePath:aImage toMovie:self.movie success:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kImageFadeDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                UIImage *oldImage = self.detailView.backdropImageView.image;
                UIImage *newImage = self.movie.backdrop;
                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                crossFade.duration = 1.0;
                crossFade.fromValue = (id)[oldImage CGImage];
                crossFade.toValue = (id)[newImage CGImage];
                [self.detailView.backdropImageView.layer addAnimation:crossFade forKey:@"animateContents"];
                self.detailView.backdropImageView.image = self.movie.backdrop;
                
                NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
                NSError *error;
                [context save:&error];
                if(error) {
                    ErrorLog("%@", [error localizedDescription]);
                }
            });
        } failure:^(NSError *error) {
            DebugLog("%@", [error localizedDescription]);
        }];
    
    // Poster
    } else {
        [bridge setPosterWithImagePath:aImage toMovie:self.movie success:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kImageFadeDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                UIImage *oldImage = self.detailView.posterImageView.image;
                UIImage *newImage = self.movie.poster;
                CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                crossFade.duration = 2.0;
                crossFade.fromValue = (id)[oldImage CGImage];
                crossFade.toValue = (id)[newImage CGImage];
                [self.detailView.posterImageView.layer addAnimation:crossFade forKey:@"animateContents"];
                self.detailView.posterImageView.image = newImage;
                
                NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
                NSError *error;
                [context save:&error];
                if(error) {
                    ErrorLog("%@", [error localizedDescription]);
                }
            });
        } failure:^(NSError *error) {
            DebugLog("%@", [error localizedDescription]);
        }];
    }
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MetaTableCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    [cell setAccessoryView:accessoryView];
    
    cell.userInteractionEnabled = YES;
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"191919"];
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            // trailer
            cell.textLabel.text = NSLocalizedString(@"BUTTON_WATCH_TRAILER", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon-trailer"];
        } else if (indexPath.row == 1) {
            // cast
            cell.textLabel.text = NSLocalizedString(@"BUTTON_SHOW_CAST", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon-cast"];
        } else {
            // Similar Movies
            cell.textLabel.text = NSLocalizedString(@"BUTTON_SIMILAR", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon-similiar"];
        }
    }
    return cell;
}

- (float)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJCellPosition position = [aTableView positionForIndexPath:indexPath];
    if(position == MJCellPositionTopAndBottom) {
        return 44.0f;
    }
    return 43.0f;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            // trailer
            [self trailerRowClicked];
        } else if (indexPath.row == 1) {
            // cast
            [self castsRowClicked];
        } else {
            // Similar Movies
            [self similarRowClicked];
        }
    }
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView.title isEqualToString:NSLocalizedString(@"DETAIL_POP_DELETE_TITLE", nil)]) {
        if(buttonIndex == 1) {
            [self deleteMovie];
        }
    }
}



@end

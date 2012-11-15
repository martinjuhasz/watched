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
#import <Social/Social.h>
#import "OnlineMovieDatabase.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MovieCastsTableViewController.h"
#import "MovieNoteViewController.h"
#import "ThumbnailPickerViewController.h"
#import "OnlineDatabaseBridge.h"
#import <QuartzCore/QuartzCore.h>
#import "WatchedWebBrowser.h"
#import "SearchMovieViewController.h"
#import "AFImageRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "UIButton+Additions.h"
#import "MJCustomTableViewCell.h"
#import "MJCustomAccessoryControl.h"
#import "BlockActionSheet.h"
#import "BlockAlertView.h"
#import "MJInternetConnection.h"

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
        // Custom initializatio
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // add detail view
    CGRect detailRect = self.view.bounds;
    detailRect.size.height = detailRect.size.height - 44.0f;
    self.detailView = [[MovieDetailView alloc] initWithFrame:detailRect];
    [self.view addSubview:self.detailView];
    
    self.detailView.ratingView.delegate = self;
    isLoadingImages = NO;
    
    // set contents and enable buttone
    [self setContent];

    [self.detailView.backdropButton addTarget:self action:@selector(posterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.posterButton addTarget:self action:@selector(posterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailView.watchedControl addTarget:self action:@selector(watchedControlChanged:) forControlEvents:UIControlEventValueChanged];
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

- (void)viewWillAppear:(BOOL)animated
{
	NSIndexPath *selection = [self.detailView.metaTableView indexPathForSelectedRow];
	if (selection) [self.detailView.metaTableView deselectRowAtIndexPath:selection animated:YES];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content Management

- (void)setContent
{
    self.title = self.movie.title;
    self.detailView.metaTableView.dataSource = self;
    self.detailView.metaTableView.delegate = self;
    self.detailView.titleLabel.text = self.movie.title;
    self.detailView.ratingView.rating = [self.movie.rating floatValue];
    
    // Director
    if(self.movie.director) {
        self.detailView.directorLabel.text = self.movie.director.name;
    } else {
        self.detailView.directorLabel.text = @"-";
    }
    
    // Overview
    if (self.movie.overview) {
        self.detailView.overviewLabel.text = self.movie.overview;
    } else {
        self.detailView.overviewLabel.text = NSLocalizedString(@"OVERVIEW_NO-CONTENT", nil);
    }
    
    // Release Date
    if (self.movie.releaseDate) {
        [self.detailView.releaseDateButton setTitle:self.movie.releaseDateFormatted];
    } else {
        [self.detailView.releaseDateButton setTitle:@"-"];
    }
    
    // RUNTIME
    if([self.movie.runtime floatValue] > 0) {
        [self.detailView.runtimeButton setTitle:self.movie.runtimeFormatted];
    } else {
        [self.detailView.runtimeButton setTitle:@"-"];
    }
    
    // Poster
    if (self.movie.poster) {
        self.detailView.posterImageView.image = self.movie.poster;
    } else {
        self.detailView.posterImageView.image = [UIImage imageNamed:@"dv_placeholder-cover.png"];
    }
    
    // Backdrop
    if (self.movie.backdrop) {
         self.detailView.backdropImageView.image = self.movie.backdrop;
    } else {
        self.detailView.backdropImageView.image = [UIImage imageNamed:@"dv_placeholder-backdrop.png"];
    }
    
    self.detailView.watchedControl.selectedSegmentIndex = (self.movie.watchedOn) ? 0 : 1;
    
    // year
    if(self.movie.releaseDate) {
        NSUInteger componentFlags = NSYearCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:self.movie.releaseDate];
        NSInteger year = [components year];
        self.detailView.yearLabel.text = [NSString stringWithFormat:@"%d", year];
    }
    
    // actors
    NSSortDescriptor *actorSort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortedCast = [[self.movie.casts allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:actorSort]];
    if(sortedCast.count <= 0) {
        self.detailView.actor1Label.text = @"-";
    }
    if(sortedCast.count >= 1) {
        Cast *cast1 = (Cast*)[sortedCast objectAtIndex:0];
        self.detailView.actor1Label.text = cast1.name;
    }
    if(sortedCast.count >= 2) {
        Cast *cast2 = (Cast*)[sortedCast objectAtIndex:1];
        self.detailView.actor2Label.text = cast2.name;
    }
    if(sortedCast.count >= 3) {
        Cast *cast3 = (Cast*)[sortedCast objectAtIndex:2];
        self.detailView.actor3Label.text = cast3.name;
    }
    
    if(sortedCast.count >= 4) {
        Cast *cast4 = (Cast*)[sortedCast objectAtIndex:3];
        self.detailView.actor4Label.text = cast4.name;
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
        SearchMovieViewController *detailViewController = (SearchMovieViewController*)segue.destinationViewController;
        detailViewController.movieID = self.movie.movieID;
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

- (IBAction)posterButtonClicked:(id)sender
{
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
        return;
    }
    
    if(isLoadingImages) return;
    isLoadingImages = YES;
    
    ImageType selectedType = ((UIButton*)sender == self.detailView.posterButton) ? ImageTypePoster : ImageTypeBackdrop;
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
        XLog("%@", [error localizedDescription]);
    }];
    [operation start];
}

- (void)newRating:(DLStarRatingControl *)control :(float)newRating
{
    // toggle to seen
    if([self.movie.rating intValue] == 0 && newRating > 0 && self.detailView.watchedControl.selectedSegmentIndex != 0) {
        [self setWatchedStateToSeen:YES];
        self.detailView.watchedControl.selectedSegmentIndex = 0;
    }
    
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

- (void)trailerRowClicked
{
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
    
    if(!self.movie.bestTrailer) return;
    NSURL *videoURL = nil;
    
    if([self.movie.bestTrailer.source isEqualToString:@"quicktime"]) {
        videoURL = [NSURL URLWithString:self.movie.bestTrailer.url];
    } else {
        videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@",self.movie.bestTrailer.url]];
    }
    [[UIApplication sharedApplication] openURL:videoURL];
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

- (IBAction)noteRowClicked
{
    [self performSegueWithIdentifier:@"MovieNoteSegue" sender:self];
}

- (IBAction)watchedControlChanged:(id)sender
{
    NSInteger selectedIndex = self.detailView.watchedControl.selectedSegmentIndex;
    if(selectedIndex == 0) {
        [self setWatchedStateToSeen:YES];
    } else {
        [self setWatchedStateToSeen:NO];
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
    BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:NSLocalizedString(@"SHARE_BUTTON_TITLE",nil)];
    
    // E-Mail
    if([MFMailComposeViewController canSendMail]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_EMAIL",nil) block:^{
            [self shareWithEmail];
        }];
    }
    
    // iMessage
    if([MFMessageComposeViewController canSendText]) {
        [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_TEXT",nil) block:^{
            [self shareWithMessage];
        }];
    }
    
    // Twitter
    [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_TWITTER",nil) block:^{
        [self shareWithService:SLServiceTypeTwitter];
    }];
    
    // Facebook
    [sheet addButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_FACEBOOK",nil) block:^{
        [self shareWithService:SLServiceTypeFacebook];
    }];
    
    // Cancel Button
    [sheet setCancelButtonWithTitle:NSLocalizedString(@"SHARE_BUTTON_CANCEL",nil) block:nil];
    
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
    
}

- (IBAction)deleteButtonClicked:(id)sender
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_TITLE", nil)
                                                   message:NSLocalizedString(@"DETAIL_POP_DELETE_CONTENT", nil)];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_CANCEL", nil) block:nil];
    [alert setDestructiveButtonWithTitle:NSLocalizedString(@"DETAIL_POP_DELETE_OK", nil) block:^{
        [self deleteMovie];
    }];
    [alert show];
    
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
            XLog("%@", [error localizedDescription]);
        }
        
    });
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)similarRowClicked
{
    if(![[MJInternetConnection sharedInternetConnection] internetAvailable]) {
        [[MJInternetConnection sharedInternetConnection] displayAlert];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.detailView.metaTableView deselectRowAtIndexPath:path animated:YES];
        return;
    }
    
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
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:title message:message];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"DETAIL_POP_NOACCOUNT_OK", nil) block:nil];
        [alert show];
        
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
    NSString *imageURL = [[[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:self.movie.posterURL imageType:ImageTypeBackdrop nearWidth:260.0f] absoluteString];
 
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###IMAGE_URL###" withString:imageURL];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_TITLE###" withString:self.movie.title];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_DESCRIPTION###" withString:self.movie.overview];
    sharebymailString = [sharebymailString stringByReplacingOccurrencesOfString:@"###MOVIE_ID###" withString:[self.movie.movieID stringValue]];
    
    
    int rating = [self.movie.rating intValue];
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
    }
    
    
    // Generate Mail Composer and View it
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:self.movie.title];
    [mailViewController setMessageBody:sharebymailString isHTML:YES];
    
    [self presentModalViewController:mailViewController animated:YES];
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
    
    [self presentModalViewController:messageViewController animated:YES];
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
#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
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
    
    if([[returnDict objectForKey:@"urls"] count] > 1) {
        [self performSegueWithIdentifier:@"ThumbnailPickerSegue" sender:returnDict];
    } else {
        
        BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"PICKER_POP_NOPOSTER_TITLE", nil)
                                                       message:NSLocalizedString(@"PICKER_POP_NOPOSTER_CONTENT", nil)];
        
        [alert setCancelButtonWithTitle:NSLocalizedString(@"PICKER_POP_NOPOSTER_OK", nil) block:nil];
        [alert show];
    }
    
}

- (void) thumbnailPicker:(ThumbnailPickerViewController*)aPicker didSelectImage:(NSString*)aImage forImageType:(ImageType)aImageType
{
    [self.navigationController popViewControllerAnimated:YES];
    OnlineDatabaseBridge *bridge = [[OnlineDatabaseBridge alloc] init];
    
    // Backdrop
    if(aImageType == ImageTypeBackdrop) {
        [bridge setBackdropWithImagePath:aImage toMovie:self.movie success:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kImageFadeDelay * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *oldImage = self.detailView.backdropImageView.image;
                    UIImage *newImage = self.movie.backdrop;
                    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                    crossFade.duration = 1.0;
                    crossFade.fromValue = (id)[oldImage CGImage];
                    crossFade.toValue = (id)[newImage CGImage];
                    [self.detailView.backdropImageView.layer addAnimation:crossFade forKey:@"animateContents"];
                    self.detailView.backdropImageView.image = self.movie.backdrop;
                });
                
                NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
                NSError *error;
                [context save:&error];
                if(error) {
                    XLog("%@", [error localizedDescription]);
                }
            });
        } failure:^(NSError *error) {
            XLog("%@", [error localizedDescription]);
        }];
    
    // Poster
    } else {
        [bridge setPosterWithImagePath:aImage toMovie:self.movie success:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kImageFadeDelay * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *oldImage = self.detailView.posterImageView.image;
                    UIImage *newImage = self.movie.poster;
                    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
                    crossFade.duration = 2.0;
                    crossFade.fromValue = (id)[oldImage CGImage];
                    crossFade.toValue = (id)[newImage CGImage];
                    [self.detailView.posterImageView.layer addAnimation:crossFade forKey:@"animateContents"];
                    self.detailView.posterImageView.image = newImage;
                });
                
                NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
                NSError *error;
                [context save:&error];
                if(error) {
                    XLog("%@", [error localizedDescription]);
                }
            });
        } failure:^(NSError *error) {
            XLog("%@", [error localizedDescription]);
        }];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 3;
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MetaTableCell";
    MJCustomTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MJCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
    [cell setAccessoryView:accessoryView];
    
    cell.userInteractionEnabled = YES;
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            // trailer
            cell.textLabel.text = NSLocalizedString(@"BUTTON_WATCH_TRAILER", nil);
            if(!self.movie.bestTrailer) {
                cell.activated = NO;
                cell.userInteractionEnabled = NO;
                accessoryView.controlImageView.image = [UIImage imageNamed:@"g_table-accessory_disabled.png"];
                cell.imageView.image = [UIImage imageNamed:@"dv_icon_trailer_disabled.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"dv_icon_trailer.png"];
            }
        } else if (indexPath.row == 1) {
            // cast
            cell.textLabel.text = NSLocalizedString(@"BUTTON_SHOW_CAST", nil);
            if(self.movie.casts.count <= 0) {
                cell.activated = NO;
                cell.userInteractionEnabled = NO;
                accessoryView.controlImageView.image = [UIImage imageNamed:@"g_table-accessory_disabled.png"];
                cell.imageView.image = [UIImage imageNamed:@"dv_icon_cast_disabled.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"dv_icon_cast.png"];
            }
        } else {
            // website
            cell.textLabel.text = NSLocalizedString(@"BUTTON_VISIT_HOMEPAGE", nil);
            if(!self.movie.homepage) {
                cell.activated = NO;
                cell.userInteractionEnabled = NO;
                accessoryView.controlImageView.image = [UIImage imageNamed:@"g_table-accessory_disabled.png"];
                cell.imageView.image = [UIImage imageNamed:@"dv_icon_website_disabled.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"dv_icon_website.png"];
            }
        }
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            // Similar Movies
            cell.textLabel.text = NSLocalizedString(@"BUTTON_SIMILAR", nil);
            cell.imageView.image = [UIImage imageNamed:@"dv_icon_similar.png"];
        } else if (indexPath.row == 1) {
            // cast
            cell.textLabel.text = NSLocalizedString(@"BUTTON_ADD_NOTE", nil);
            cell.imageView.image = [UIImage imageNamed:@"dv_icon_notes.png"];
        }
        [cell setAccessoryView:nil];
    }
    
    
    // Configure the cell...
    [cell configureForTableView:aTableView indexPath:indexPath];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    MJCellPosition position = [self positionForIndexPath:indexPath inTableView:self.tableView];
    //    if(position == MJCellPositionTop) {
    //        return 44.0f;
    //    }
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
            // website
            [self websiteRowClicked];
        }
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            // Similar Movies
            [self similarRowClicked];
        } else if (indexPath.row == 1) {
            // Notes
            [self noteRowClicked];
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

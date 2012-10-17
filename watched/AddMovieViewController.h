//
//  AddMovieViewController.h
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;
@class Movie;

@protocol AddMovieViewDelegate;

@interface AddMovieViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *displayView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *overviewLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;
@property (strong, nonatomic) IBOutlet UILabel *overviewTitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *scrollTopFadeView;
@property (strong, nonatomic) IBOutlet UIImageView *scrollBottomFadeView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) SearchResult *searchResult;
@property (strong, nonatomic) NSNumber *resultID;
@property (strong, nonatomic) UIImage *coverImage;
@property (assign, nonatomic) id <AddMovieViewDelegate>delegate;
@property (strong, nonatomic) Movie *movie;

- (IBAction)cancelButtonClicked:(id)sender;



@end

@protocol AddMovieViewDelegate<NSObject>
@optional
- (void)AddMovieControllerCancelButtonClicked:(AddMovieViewController*)addMovieViewController;
@end

//
//  AddMovieViewController.h
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchResult;
@protocol AddMovieViewDelegate;

@interface AddMovieViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *overviewLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) SearchResult *searchResult;
@property (strong, nonatomic) UIImage *coverImage;
@property (assign, nonatomic) id <AddMovieViewDelegate>delegate;

- (IBAction)cancelButtonClicked:(id)sender;



@end

@protocol AddMovieViewDelegate<NSObject>
@optional
- (void)AddMovieControllerCancelButtonClicked:(AddMovieViewController*)addMovieViewController;
@end

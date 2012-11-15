//
//  MoviePopupViewController.h
//  watched
//
//  Created by Martin Juhasz on 17.10.12.
//
//

#import <UIKit/UIKit.h>

@class MoviePopupView;
@class Movie;
@class SearchResult;
@protocol MoviePopupViewControllerDelegate;

@interface MoviePopupViewController : UIViewController

@property (strong, nonatomic) MoviePopupView *popupView;
@property (assign, nonatomic) id <MoviePopupViewControllerDelegate>delegate;
@property (assign, nonatomic) BOOL appeard;

@property (strong, nonatomic) SearchResult *searchResult;
@property (strong, nonatomic) NSNumber *resultID;
@property (strong, nonatomic) Movie *movie;

@end



@protocol MoviePopupViewControllerDelegate<NSObject>
@optional
- (void)moviePopupCancelButtonClicked:(MoviePopupViewController*)moviePopupViewController;
@end
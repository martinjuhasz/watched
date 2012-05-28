//
//  MovieDetailViewController.h
//  watched
//
//  Created by Martin Juhasz on 28.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"

@class Movie;

@interface MovieDetailViewController : UIViewController<DLStarRatingDelegate>

@property (nonatomic, strong) Movie *movie;

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *backdropImageView;
@property (strong, nonatomic) IBOutlet UIImageView *posterImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *runtimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *imdbRatingLabel;
@property (strong, nonatomic) IBOutlet UILabel *overviewLabel;
@property (strong, nonatomic) IBOutlet DLStarRatingControl *ratingView;

@end

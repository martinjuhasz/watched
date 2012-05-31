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
@class MovieDetailView;

@interface MovieDetailViewController : UIViewController<DLStarRatingDelegate>

@property (nonatomic, strong) Movie *movie;
@property (nonatomic, strong) MovieDetailView *detailView;

@end

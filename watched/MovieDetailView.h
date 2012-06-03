//
//  MovieDetailView.h
//  watched
//
//  Created by Martin Juhasz on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"

@interface MovieDetailView : UIView

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIImageView *backdropImageView;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UISwitch *watchedSwitch;
@property (strong, nonatomic) UILabel *releaseDateLabel;
@property (strong, nonatomic) UILabel *runtimeLabel;
@property (strong, nonatomic) UIImageView *actor1ImageView;
@property (strong, nonatomic) UILabel *actor1Label;
@property (strong, nonatomic) UIImageView *actor2ImageView;
@property (strong, nonatomic) UILabel *actor2Label;
@property (strong, nonatomic) UIImageView *actor3ImageView;
@property (strong, nonatomic) UILabel *actor3Label;
@property (strong, nonatomic) UILabel *overviewLabel;
@property (strong, nonatomic) DLStarRatingControl *ratingView;
@property (strong, nonatomic) UIButton *noteButton;
@property (strong, nonatomic) UIButton *trailerButton;
@property (strong, nonatomic) UIButton *castsButton;
@property (strong, nonatomic) UIButton *websiteButton;

@end

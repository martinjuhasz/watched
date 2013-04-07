//
//  MovieDetailView.h
//  watched
//
//  Created by Martin Juhasz on 29.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"
#import "OnlineMovieDatabase.h"
#import "MJGradientView.h"
#import "MJSegmentedControl.h"

@interface MovieDetailView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIView *imageLoadingView;
@property (strong, nonatomic) UIImageView *backdropImageView;
@property (strong, nonatomic) UIImageView *backdropBottomShadow;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UIButton *backdropButton;
@property (strong, nonatomic) UIButton *posterButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *yearLabel;
@property (strong, nonatomic) MJSegmentedControl *watchedControl;
@property (strong, nonatomic) UILabel *directorLabel;
@property (strong, nonatomic) UIButton *releaseDateButton;
@property (strong, nonatomic) UIButton *runtimeButton;
@property (strong, nonatomic) UILabel *releaseDateTitleLabel;
@property (strong, nonatomic) UILabel *runtimeTitleLabel;
@property (strong, nonatomic) UILabel *actor1Label;
@property (strong, nonatomic) UILabel *actor2Label;
@property (strong, nonatomic) UILabel *actor3Label;
@property (strong, nonatomic) UILabel *actor4Label;
@property (strong, nonatomic) UILabel *overviewLabel;
@property (strong, nonatomic) UILabel *overviewTitleLabel;
@property (strong, nonatomic) DLStarRatingControl *ratingView;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) MJGradientView *movieDetailsBackgroundView;
@property (strong, nonatomic) MJGradientView *overviewBackgroundView;
@property (strong, nonatomic) MJGradientView *overviewBottomDividerView;
@property (strong, nonatomic) MJGradientView *overviewBottomDividerDropshadowView;
@property (strong, nonatomic) UIView *bottomBackgroundView;
@property (strong, nonatomic) UITableView *metaTableView;

- (void)toggleLoadingViewForPosterType:(ImageType)aImageType;

@end

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
#import "MJUAddButton.h"

@interface MovieDetailView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UIView *imageLoadingView;
@property (strong, nonatomic) UIImageView *backdropImageView;
@property (strong, nonatomic) UIImageView *backdropBottomShadow;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (strong, nonatomic) UIButton *backdropButton;
@property (strong, nonatomic) UIButton *posterButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *directorLabel;
@property (strong, nonatomic) UILabel *releaseDateTitleLabel;
@property (strong, nonatomic) UILabel *runtimeTitleLabel;
@property (strong, nonatomic) UILabel *actor1Label;
@property (strong, nonatomic) UILabel *actor2Label;
@property (strong, nonatomic) UILabel *actor3Label;
@property (strong, nonatomic) UILabel *actor4Label;
@property (strong, nonatomic) UILabel *releaseLabel;
@property (strong, nonatomic) UILabel *runtimeLabel;
@property (strong, nonatomic) UILabel *overviewLabel;
@property (strong, nonatomic) UILabel *overviewTitleLabel;
@property (strong, nonatomic) DLStarRatingControl *ratingView;
@property (strong, nonatomic) UITableView *metaTableView;
@property (strong, nonatomic) UILabel *directorTitleLabel;
@property (strong, nonatomic) UILabel *starringTitleLabel;
@property (strong, nonatomic) MJUAddButton *addToCollectionButton;

@property (strong, nonatomic) UIView *notesView;
@property (strong, nonatomic) UILabel *notesTitleLabel;
@property (strong, nonatomic) UILabel *notesLabel;
@property (strong, nonatomic) UIButton *notesEditButton;

@property (strong, nonatomic) UIView *informationView;
@property (strong, nonatomic) CALayer *informationViewtableBorderBottom;

- (void)toggleLoadingViewForPosterType:(ImageType)aImageType;
- (void)switchToAddedState;
- (void)setToNonAddedState;

@end

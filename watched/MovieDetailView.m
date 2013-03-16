//
//  MovieDetailView.m
//  watched
//
//  Created by Martin Juhasz on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieDetailView.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "UIButton+Additions.h"
#import "UILabel+Additions.h"
#import <QuartzCore/QuartzCore.h>


@implementation MovieDetailView

#define kMBackdropHeight 190.0f
#define kMBackdropScrollStop 50.0f

//#define kContentFont @"HelveticaNeue-Bold"
#define kContentFont @"HelveticaNeue"

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupContent];
        [self firstLayout];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content Management

- (void)firstLayout
{
    self.backdropImageView.frame = CGRectMake(-60.0f, 0.0f, 440.0f, kMBackdropHeight);
    self.backdropBottomShadow.frame = CGRectMake(0.0f, 0.0f, 320.0f, kMBackdropHeight);
    self.posterImageView.frame = CGRectMake(11.0f, 136.0f, 71.0f, 99.0f);
    self.backdropButton.frame = CGRectMake(0.0f, 0.0f, 320.0f, 120.0f);
    self.posterButton.frame = CGRectMake(11.0f, 136.0f, 71.0f, 99.0f);
    self.watchedControl.frame = CGRectMake(101.0f, 207.0f, 209.0f, 30.0f);
    self.ratingView.frame = CGRectMake(0.0f, 251.0f, 320.0f, 55.0f);
    self.directorLabel.frame = CGRectMake(100.0f, 318.0f, 165.0f, 20.0f);
    self.actor1Label.frame = CGRectMake(100.0f, 343.0f, 165.0f, 20.0f);
    self.actor2Label.frame = CGRectMake(100.0f, 361.0f, 165.0f, 20.0f);
    self.actor3Label.frame = CGRectMake(100.0f, 379.0f, 165.0f, 20.0f);
    self.actor4Label.frame = CGRectMake(100.0f, 397.0f, 165.0f, 20.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel sizeToFitWithWith:165.0f andMaximumNumberOfLines:2];
    self.titleLabel.frame = CGRectMake(101.0f, 137.0f, 165.0f, self.titleLabel.frame.size.height);
    self.yearLabel.frame = CGRectMake(101.0f, self.titleLabel.bottom + 3.0f, 165.0f, 20.0f);
    CGFloat lastPostition = 343.0f;
    
    if(self.actor1Label.text) lastPostition += 20.0f;
    if(self.actor2Label.text) lastPostition += 20.0f;
    if(self.actor3Label.text) lastPostition += 20.0f;
    if(self.actor4Label.text) lastPostition += 20.0f;
    
    // add extra space for time and release date
    lastPostition += 47.0f;
    
    self.movieDetailsBackgroundView.height = lastPostition - self.movieDetailsBackgroundView.top;
    self.releaseDateButton.frame = CGRectMake(165.0f, lastPostition - 40.0f, 145.0f, 25.0f);
    self.runtimeButton.frame = CGRectMake(10.0f, lastPostition - 40.0f, 145.0f, 25.0f);
    self.runtimeTitleLabel.frame = CGRectMake(20.0f, lastPostition - 40.0f, 145.0f, 25.0f);
    self.releaseDateTitleLabel.frame = CGRectMake(175.0f, lastPostition - 40.0f, 145.0f, 25.0f);
    
    self.overviewTitleLabel.frame = CGRectMake(10.0f, lastPostition + 12.0f, 300.0f, 15.0f);
    self.overviewLabel.frame = CGRectMake(10.0f, lastPostition + 28.0f, 294.0f, 0.0f);
    [self.overviewLabel sizeToFit];
    self.overviewBackgroundView.frame = CGRectMake(0.0f, lastPostition, 320.0f, self.overviewLabel.bottom - lastPostition + 16.0f);
    
    self.overviewBottomDividerView.frame = CGRectMake(0.0f, self.overviewBackgroundView.bottom, 320.0f, 10.0f);
    self.overviewBottomDividerDropshadowView.frame = CGRectMake(0.0f, self.overviewBottomDividerView.bottom, 320.0f, 3.0f);
    self.metaTableView.frame = CGRectMake(0.0f, self.overviewBottomDividerDropshadowView.top, 320.0f, 233.0f);
    
    self.bottomBackgroundView.frame = CGRectMake(0.0f, self.metaTableView.bottom, 320.0f, 70.0f);
    
    self.deleteButton.frame = CGRectMake(10.0f, self.metaTableView.bottom + 16.0f, 300.0f, 40.0f);
    
    [self.mainScrollView setContentSize:CGSizeMake(320.0f, self.bottomBackgroundView.bottom)];
}

- (void)setupContent
{
    self.backgroundColor = HEXColor(0x333433);
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.mainScrollView.delegate = self;
    [self addSubview:self.mainScrollView];
    
    self.backdropImageView = [[UIImageView alloc] init];
    self.backdropImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backdropImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.backdropImageView];
    
    self.backdropBottomShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_mask.png"]];
    self.backdropBottomShadow.contentMode = UIViewContentModeTop;
    self.backdropBottomShadow.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.backdropBottomShadow];
    
    self.backdropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mainScrollView addSubview:self.backdropButton];
    
    UIImageView *titleOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_title-overlay.png"]];
    titleOverlayImageView.frame = CGRectMake(0.0f, 119.0f, 320.0f, 132.0f);
    [self.mainScrollView addSubview:titleOverlayImageView];
    
    self.posterImageView = [[UIImageView alloc] init];
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.posterImageView];
    
    self.posterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mainScrollView addSubview:self.posterButton];

    self.imageLoadingView = [[UIView alloc] initWithFrame:CGRectZero];
    self.imageLoadingView.backgroundColor = [UIColor blackColor];
    self.imageLoadingView.alpha = 0.0f;
    self.imageLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    activityIndicator.center = self.imageLoadingView.center;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [activityIndicator startAnimating];
    [self.imageLoadingView addSubview:activityIndicator];
    
    // cover
    UIImageView *posterCover = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 134.0f, 75.0f, 103.0f)];
    posterCover.image = [UIImage imageNamed:@"dv_cover-overlay.png"];
    posterCover.contentMode = UIViewContentModeScaleAspectFill;
    posterCover.clipsToBounds = YES;
    [self.mainScrollView addSubview:posterCover];
    
    self.titleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.titleLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.textColor = HEXColor(0x000000);
    self.titleLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.titleLabel];
    
    self.yearLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.yearLabel];
    self.yearLabel.font = [UIFont systemFontOfSize:14.0f];
    self.yearLabel.adjustsFontSizeToFitWidth = NO;
    self.yearLabel.textColor = HEXColor(0x919191);
    self.yearLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    self.yearLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.yearLabel];
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 306.0f, 320.0f, 1.0f)];
    divider.backgroundColor = [UIColor blackColor];
    [self.mainScrollView addSubview:divider];
    
    self.movieDetailsBackgroundView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, 307.0f, 320.0f, 100.0f)];
    self.movieDetailsBackgroundView.startColor = HEXColor(0x5A5A5A);
    self.movieDetailsBackgroundView.stopColor = HEXColor(0x464646);
    self.movieDetailsBackgroundView.topColor = HEXColor(0x757575);
    self.movieDetailsBackgroundView.bottomColor = HEXColor(0x000000);
    [self.mainScrollView addSubview:self.movieDetailsBackgroundView];
    
    UILabel *directorTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 318.0f, 165.0f, 20.0f)];
    directorTitleLabel.text = [ NSLocalizedString(@"DETAIL_DIRECTOR_TITLE", nil) uppercaseString];
    [self setDefaultStylesForLabels:directorTitleLabel];
    directorTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    directorTitleLabel.adjustsFontSizeToFitWidth = NO;
    directorTitleLabel.textColor = HEXColor(0xFFFFFF);
    directorTitleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    directorTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:directorTitleLabel];
    
    UILabel *starringTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 343.0f, 165.0f, 20.0f)];
    starringTitleLabel.text = [NSLocalizedString(@"DETAIL_STARRING_TITLE", nil) uppercaseString];
    [self setDefaultStylesForLabels:starringTitleLabel];
    starringTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    starringTitleLabel.adjustsFontSizeToFitWidth = NO;
    starringTitleLabel.textColor = HEXColor(0xFFFFFF);
    starringTitleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    starringTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:starringTitleLabel];
    
    self.watchedControl = [[MJSegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                     NSLocalizedString(@"DV_CONTROL_WATCHED", nil),
                                                                     NSLocalizedString(@"DV_CONTROL_UNWATCHED", nil), nil]];
    
    UIImage *segmentedControlBgImage = [[UIImage imageNamed:@"dv_watched.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *segmentedControlBgImageActive = [[UIImage imageNamed:@"dv_watched-highlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
    UIImage *segmentedDividerNN = [UIImage imageNamed:@"dv_watched-dv-nn.png"];
    UIImage *segmentedDividerAN = [UIImage imageNamed:@"dv_watched-dv-an.png"];
    UIImage *segmentedDividerNA = [UIImage imageNamed:@"dv_watched-dv-na.png"];
    
    
    [self.watchedControl setBackgroundImage:segmentedControlBgImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.watchedControl setBackgroundImage:segmentedControlBgImageActive forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.watchedControl setDividerImage:segmentedDividerNN forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.watchedControl setDividerImage:segmentedDividerAN forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.watchedControl setDividerImage:segmentedDividerNA forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [self.mainScrollView addSubview:self.watchedControl];
    
    self.ratingView =[[DLStarRatingControl alloc] initWithFrame:CGRectMake(0.0f, 251.0f, 320.0f, 55.0f) andStars:5 isFractional:NO];
    self.ratingView.star = [UIImage imageNamed:@"dv_star.png"];
    self.ratingView.highlightedStar = [UIImage imageNamed:@"dv_star-highlighted.png"];
    self.ratingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dv_bg_rating.png"]];
    [self.mainScrollView addSubview:self.ratingView];
    
    
    self.metaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 277.0f) style:UITableViewStyleGrouped];
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-grp_table.png"]];
    self.metaTableView.backgroundView = backgroundView;
    self.metaTableView.scrollEnabled = NO;
    self.metaTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.metaTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-grp_table.png"]];
    self.metaTableView.contentInset = UIEdgeInsetsMake(10.0f, 0.0f, 15.0f, 0.0f);
    [self.mainScrollView addSubview:self.metaTableView];
    
    
    
    
    
    
    
    
    
    
    
     
    self.directorLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.directorLabel];
    self.directorLabel.font = [UIFont fontWithName:kContentFont size:12.0f];
    self.directorLabel.adjustsFontSizeToFitWidth = NO;
    self.directorLabel.textColor = HEXColor(0xD1D1D1);
    self.directorLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.directorLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.directorLabel];

    UIImage *metaBackground = [[UIImage imageNamed:@"dv_bg-meta.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    
    self.releaseDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.releaseDateButton.titleLabel.font = [UIFont fontWithName:kContentFont size:10.0f];
    self.releaseDateButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.releaseDateButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.releaseDateButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.releaseDateButton setTitleColor:HEXColor(0xD1D1D1)];
    self.releaseDateButton.contentHorizontalAlignment = NSTextAlignmentRight;
    self.releaseDateButton.titleEdgeInsets = UIEdgeInsetsMake(1.0f, 10.0f, 0.0f, 10.0f);
    [self.releaseDateButton setBackgroundImage:metaBackground];
    [self.mainScrollView addSubview:self.releaseDateButton];
    
    self.runtimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.runtimeButton.titleLabel.font = [UIFont fontWithName:kContentFont size:10.0f];
    self.runtimeButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.runtimeButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.runtimeButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    [self.runtimeButton setTitleColor:HEXColor(0xD1D1D1)];
    self.runtimeButton.contentHorizontalAlignment = NSTextAlignmentRight;
    self.runtimeButton.titleEdgeInsets = UIEdgeInsetsMake(1.0f, 10.0f, 0.0f, 10.0f);
    [self.runtimeButton setBackgroundImage:metaBackground];
    [self.mainScrollView addSubview:self.runtimeButton];

    self.releaseDateTitleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.releaseDateTitleLabel];
    self.releaseDateTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    self.releaseDateTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.releaseDateTitleLabel.textColor = HEXColor(0xFFFFFF);
    self.releaseDateTitleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.releaseDateTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.releaseDateTitleLabel.text = [NSLocalizedString(@"DETAIL_RELEASEDATE_TITLE", nil) uppercaseString];
    [self.mainScrollView addSubview:self.releaseDateTitleLabel];

    self.runtimeTitleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.runtimeTitleLabel];
    self.runtimeTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    self.runtimeTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.runtimeTitleLabel.textColor = HEXColor(0xFFFFFF);
    self.runtimeTitleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.runtimeTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.runtimeTitleLabel.text = [NSLocalizedString(@"DETAIL_RUNTIME_TITLE", nil) uppercaseString];
    [self.mainScrollView addSubview:self.runtimeTitleLabel];
    
    
    

    
    self.actor1Label = [[UILabel alloc] init];
    self.actor1Label.backgroundColor = [UIColor clearColor];
    self.actor1Label.font = [UIFont fontWithName:kContentFont size:12.0f];
    self.actor1Label.adjustsFontSizeToFitWidth = NO;
    self.actor1Label.textColor = HEXColor(0xD1D1D1);
    self.actor1Label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.actor1Label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.actor1Label];
    
    self.actor2Label = [[UILabel alloc] init];
    self.actor2Label.backgroundColor = [UIColor clearColor];
    self.actor2Label.font = [UIFont fontWithName:kContentFont size:12.0f];
    self.actor2Label.adjustsFontSizeToFitWidth = NO;
    self.actor2Label.textColor = HEXColor(0xD1D1D1);
    self.actor2Label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.actor2Label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.actor2Label];
    
    self.actor3Label = [[UILabel alloc] init];
    self.actor3Label.backgroundColor = [UIColor clearColor];
    self.actor3Label.font = [UIFont fontWithName:kContentFont size:12.0f];
    self.actor3Label.adjustsFontSizeToFitWidth = NO;
    self.actor3Label.textColor = HEXColor(0xD1D1D1);
    self.actor3Label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.actor3Label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.actor3Label];
    
    self.actor4Label = [[UILabel alloc] init];
    self.actor4Label.backgroundColor = [UIColor clearColor];
    self.actor4Label.font = [UIFont fontWithName:kContentFont size:12.0f];
    self.actor4Label.adjustsFontSizeToFitWidth = NO;
    self.actor4Label.textColor = HEXColor(0xD1D1D1);
    self.actor4Label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    self.actor4Label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.actor4Label];
    
    
    
    
    
    self.overviewBackgroundView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, 308.0f, 320.0f, 100.0f)];
    self.overviewBackgroundView.startColor = HEXColor(0xE6E6E6);
    self.overviewBackgroundView.stopColor = HEXColor(0xC9C9C9);
    self.overviewBackgroundView.topColor = HEXColor(0xFCFCFC);
    self.overviewBackgroundView.bottomColor = HEXColor(0x2C2C2C);
    [self.mainScrollView addSubview:self.overviewBackgroundView];
    
    self.overviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.overviewTitleLabel.text = [NSLocalizedString(@"DETAIL_DESCRIPTION_TITLE", nil) uppercaseString];
    [self setDefaultStylesForLabels:self.overviewTitleLabel];
    self.overviewTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    self.overviewTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.overviewTitleLabel.textColor = HEXColor(0x000000);
    self.overviewTitleLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    self.overviewTitleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.overviewTitleLabel];
    
    self.overviewLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.overviewLabel];
    self.overviewLabel.font = [UIFont fontWithName:kContentFont size:12.0f];
    self.overviewLabel.adjustsFontSizeToFitWidth = NO;
    self.overviewLabel.textColor = HEXColor(0x666666);
    self.overviewLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    self.overviewLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.overviewLabel];
    
    
    self.overviewBottomDividerView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, 308.0f, 320.0f, 10.0f)];
    self.overviewBottomDividerView.startColor = HEXColor(0x949494);
    self.overviewBottomDividerView.stopColor = HEXColor(0x828282);
    self.overviewBottomDividerView.topColor = HEXColor(0xA7A7A7);
    self.overviewBottomDividerView.bottomColor = HEXColor(0x2C2C2C);
    [self.mainScrollView addSubview:self.overviewBottomDividerView];
    
    self.overviewBottomDividerDropshadowView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, 308.0f, 320.0f, 3.0f)];
    self.overviewBottomDividerDropshadowView.startColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f];
    self.overviewBottomDividerDropshadowView.stopColor = [UIColor clearColor];
    [self.mainScrollView addSubview:self.overviewBottomDividerDropshadowView];
    
    
    
    self.bottomBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dv_bg-delete.png"]];
    [self.mainScrollView addSubview:self.bottomBackgroundView];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    self.deleteButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.deleteButton.titleColor = HEXColor(0xFFFFFF);
    self.deleteButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
    self.deleteButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.deleteButton setTitle:[NSLocalizedString(@"BUTTON_DELETE_MOVIE", nil) uppercaseString]];
    
    UIImage *deleteBg = [[UIImage imageNamed:@"dv_button-delete.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    UIImage *deleteBgActive = [[UIImage imageNamed:@"dv_button-delete-selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    
    [self.deleteButton setBackgroundImage:deleteBg];
    [self.deleteButton setBackgroundImage:deleteBgActive forState:UIControlStateHighlighted];
    [self.mainScrollView addSubview:self.deleteButton];
}

- (void)setDefaultStylesForLabels:(UILabel*)label
{
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat scrollViewOffset = aScrollView.contentOffset.y;

    if(scrollViewOffset < 0.0f) {
        
        // minx max
        CGFloat minVal = MIN(scrollViewOffset,-kMBackdropScrollStop);
        CGFloat maxVal = MAX(scrollViewOffset,-kMBackdropScrollStop);
        
        // Backdrop
        CGRect imageViewRect = self.backdropImageView.frame;
        imageViewRect.origin.y = scrollViewOffset;
        imageViewRect.size.height = kMBackdropHeight - maxVal;

        // Shadow
        CGRect shadowRect = self.backdropBottomShadow.frame;
        shadowRect.size.height = kMBackdropHeight - (minVal + kMBackdropScrollStop);
        shadowRect.origin.y = minVal + kMBackdropScrollStop;
        
        // Loading Button
        if(self.imageLoadingView.frame.size.width >= 320.0f && self.imageLoadingView.alpha > 0.0f) {
            // Overlay
            CGRect overlayRect = CGRectMake(0.0f, 0.0f, 320.0f, 120.0f);
            overlayRect.size.height -= scrollViewOffset;
            overlayRect.origin.y = scrollViewOffset;
            self.imageLoadingView.frame = overlayRect;
        }
        
        // set em
        self.backdropBottomShadow.frame = shadowRect;
        self.backdropImageView.frame = imageViewRect;
    }
}

- (void)toggleLoadingViewForPosterType:(ImageType)aImageType
{
    UIImageView *targetView = (aImageType == ImageTypeBackdrop) ? self.backdropImageView : self.posterImageView;
    if(aImageType == ImageTypeBackdrop) {
        self.imageLoadingView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 120.0f);
    } else {
        self.imageLoadingView.frame = targetView.frame;
    }
    

    if(self.imageLoadingView.alpha <= 0.0f) {
        [self.mainScrollView insertSubview:self.imageLoadingView aboveSubview:targetView];
        [UIView animateWithDuration:(0.2) animations:^{
            self.imageLoadingView.alpha = 0.5f;
        }];
    } else {
        [UIView animateWithDuration:(0.2) animations:^{
            self.imageLoadingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.imageLoadingView removeFromSuperview];
        }];
    }
}

@end

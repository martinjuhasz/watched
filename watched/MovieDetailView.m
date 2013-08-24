//
//  MovieDetailView.m
//  watched
//
//  Created by Martin Juhasz on 29.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "MovieDetailView.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "UIButton+Additions.h"
#import "UILabel+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Additions.h"


@implementation MovieDetailView

#define kMBackdropHeight 110.0f
#define kMBackdropScrollStop 100.0f

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
    self.posterImageView.frame = CGRectMake(16.0f, 126.0f, 71.0f, 99.0f);
    self.posterButton.frame = CGRectMake(16.0f, 126.0f, 71.0f, 99.0f);
    self.backdropButton.frame = CGRectMake(0.0f, 0.0f, 320.0f, 120.0f);
    
    self.metaTableView.frame = CGRectMake(16.0f, 247.0f, 305.0f, 129.0f);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(103.0f, 135.0f, 200.0f, self.titleLabel.frame.size.height);
    [self.titleLabel sizeToFitWithWith:200.0f andMaximumNumberOfLines:2];
    
    self.ratingView.frame = CGRectMake(100.0f, self.titleLabel.bottom+10.0f, 168.0f, 35.0f);
    
    self.overviewTitleLabel.frame = CGRectMake(16.0f, 400.0f, 290.0f, 20.0f);
    [self.overviewTitleLabel sizeToFitWithWith:290.0f andMaximumNumberOfLines:3];
    
    CGFloat lastPostition = 400.0f;
    if([self.overviewTitleLabel.text length] > 0) lastPostition += 30.0f;
    
    
    self.overviewLabel.frame = CGRectMake(16.0f, lastPostition, 290.0f, 0.0f);
    [self.overviewLabel sizeToFit];
    
    CGFloat lastPostitionInformationView = 70.0f;
    self.directorTitleLabel.frame = CGRectMake(16.0f, 40.0f, 165.0f, 20.0f);
    self.starringTitleLabel.frame = CGRectMake(16.0f, 70.0f, 165.0f, 20.0f);
    self.directorLabel.frame = CGRectMake(100.0f, 40.0f, 165.0f, 20.0f);
    self.actor1Label.frame = CGRectMake(100.0f, 70.0f, 165.0f, 20.0f);
    self.actor2Label.frame = CGRectMake(100.0f, 90.0f, 165.0f, 20.0f);
    self.actor3Label.frame = CGRectMake(100.0f, 110.0f, 165.0f, 20.0f);
    self.actor4Label.frame = CGRectMake(100.0f, 130.0f, 165.0f, 20.0f);
    
    if([self.actor2Label.text length] > 0) lastPostitionInformationView += 20.0f;
    if([self.actor3Label.text length] > 0) lastPostitionInformationView += 20.0f;
    if([self.actor4Label.text length] > 0) lastPostitionInformationView += 20.0f;
    lastPostitionInformationView += 30.0f;
    
    self.releaseDateTitleLabel.frame = CGRectMake(16.0f, lastPostitionInformationView, 165.0f, 20.0f);
    self.releaseLabel.frame = CGRectMake(100.0f, lastPostitionInformationView, 165.0f, 20.0f);
    lastPostitionInformationView += 30.0f;
    self.runtimeTitleLabel.frame = CGRectMake(16.0f, lastPostitionInformationView, 165.0f, 20.0f);
    self.runtimeLabel.frame = CGRectMake(100.0f, lastPostitionInformationView, 165.0f, 20.0f);
    
    self.informationView.frame = CGRectMake(0.0f, self.overviewLabel.bottom + 25.0f, 320.0f, self.runtimeLabel.bottom + 30.0f);
    CALayer *informationViewtableBorderBottom = [CALayer layer];
    informationViewtableBorderBottom.frame = CGRectMake(16.0f, self.informationView.height-1.0f, self.informationView.frame.size.width - 15, 0.5f);
    informationViewtableBorderBottom.backgroundColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
    [self.informationView.layer addSublayer:informationViewtableBorderBottom];
    
    self.notesLabel.frame = CGRectMake(16.0f, 40.0f, 290.0f, 0.0f);
    [self.notesLabel sizeToFit];
    self.notesView.frame = CGRectMake(0.0f, self.informationView.bottom, 320.0f, self.notesLabel.bottom + 16.0f);
    
    [self.mainScrollView setContentSize:CGSizeMake(320.0f, self.notesView.bottom + 30.0f)];
}

- (void)setupContent
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.mainScrollView.delegate = self;
    [self.mainScrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 50.0f, 0.0f)];
    [self.mainScrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0.0f, 0.0f, 65.0f, 0.0f)];
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
    UIImageView *posterCover = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 126.0f, 71.0f, 99.0f)];
    posterCover.image = [UIImage imageNamed:@"cover-overlay-detailview"];
    posterCover.contentMode = UIViewContentModeScaleAspectFill;
    posterCover.clipsToBounds = YES;
    [self.mainScrollView addSubview:posterCover];
    
    self.titleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.titleLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.textColor = HEXColor(0x191919);
    [self.mainScrollView addSubview:self.titleLabel];
    
    self.ratingView =[[DLStarRatingControl alloc] initWithFrame:CGRectMake(0.0f, 251.0f, 320.0f, 55.0f) andStars:5 isFractional:NO];
    self.ratingView.star = [UIImage imageNamed:@"rating-star"];
    self.ratingView.highlightedStar = [UIImage imageNamed:@"rating-star-highlighted"];
    [self.mainScrollView addSubview:self.ratingView];
    
    self.metaTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 129.0f) style:UITableViewStylePlain];
    self.metaTableView.scrollEnabled = NO;
    self.metaTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    CALayer *tableBorderTop = [CALayer layer];
    tableBorderTop.frame = CGRectMake(0.0f, 0.0f, self.metaTableView.frame.size.width, 0.5f);
    tableBorderTop.backgroundColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
    [self.metaTableView.layer addSublayer:tableBorderTop];
    CALayer *tableBorderBottom = [CALayer layer];
    tableBorderBottom.frame = CGRectMake(0.0f, 128.0f, self.metaTableView.frame.size.width, 0.5f);
    tableBorderBottom.backgroundColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
    [self.metaTableView.layer addSublayer:tableBorderBottom];
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    self.metaTableView.tableFooterView = emptyTable;
    [self.mainScrollView addSubview:self.metaTableView];
    
    self.overviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self setDefaultStylesForLabels:self.overviewTitleLabel];
    self.overviewTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
    self.overviewTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.overviewTitleLabel.textColor = HEXColor(0x787878);
    [self.mainScrollView addSubview:self.overviewTitleLabel];
    
    self.overviewLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.overviewLabel];
    self.overviewLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.overviewLabel.adjustsFontSizeToFitWidth = NO;
    self.overviewLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.mainScrollView addSubview:self.overviewLabel];
    
    self.informationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    CALayer *informationViewtableBorderTop = [CALayer layer];
    informationViewtableBorderTop.frame = CGRectMake(16.0f, 0.0f, self.informationView.frame.size.width - 15, 0.5f);
    informationViewtableBorderTop.backgroundColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
    [self.informationView.layer addSublayer:informationViewtableBorderTop];
    [self.mainScrollView addSubview:self.informationView];
    
    UILabel *informationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, 305.0f, 20.0f)];
    informationTitleLabel.text = NSLocalizedString(@"DETAIL_INFORMATION_TITLE", nil);
    [self setDefaultStylesForLabels:informationTitleLabel];
    informationTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
    informationTitleLabel.adjustsFontSizeToFitWidth = NO;
    informationTitleLabel.textColor = [UIColor colorWithHexString:@"191919"];
    [self.informationView addSubview:informationTitleLabel];
    
    self.directorTitleLabel = [[UILabel alloc] init];
    self.directorTitleLabel.text = NSLocalizedString(@"DETAIL_DIRECTOR_TITLE", nil);
    [self setDefaultStylesForLabels:self.directorTitleLabel];
    self.directorTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0f];
    self.directorTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.directorTitleLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.directorTitleLabel];

    self.starringTitleLabel = [[UILabel alloc] init];
    self.starringTitleLabel.text = NSLocalizedString(@"DETAIL_STARRING_TITLE", nil);
    [self setDefaultStylesForLabels:self.starringTitleLabel];
    self.starringTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0f];
    self.starringTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.starringTitleLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.starringTitleLabel];
    
    self.releaseDateTitleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.releaseDateTitleLabel];
    self.releaseDateTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0f];
    self.releaseDateTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.releaseDateTitleLabel.textColor = [UIColor colorWithHexString:@"787878"];
    self.releaseDateTitleLabel.text = NSLocalizedString(@"DETAIL_RELEASEDATE_TITLE", nil);
    [self.informationView addSubview:self.releaseDateTitleLabel];
    
    self.runtimeTitleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.runtimeTitleLabel];
    self.runtimeTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0f];
    self.runtimeTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.runtimeTitleLabel.textColor = [UIColor colorWithHexString:@"787878"];
    self.runtimeTitleLabel.text = NSLocalizedString(@"DETAIL_RUNTIME_TITLE", nil);
    [self.informationView addSubview:self.runtimeTitleLabel];

    self.directorLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.directorLabel];
    self.directorLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.directorLabel.adjustsFontSizeToFitWidth = NO;
    self.directorLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.directorLabel];
    
    self.actor1Label = [[UILabel alloc] init];
    self.actor1Label.backgroundColor = [UIColor clearColor];
    self.actor1Label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.actor1Label.adjustsFontSizeToFitWidth = NO;
    self.actor1Label.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.actor1Label];
    
    self.actor2Label = [[UILabel alloc] init];
    self.actor2Label.backgroundColor = [UIColor clearColor];
    self.actor2Label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.actor2Label.adjustsFontSizeToFitWidth = NO;
    self.actor2Label.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.actor2Label];
    
    self.actor3Label = [[UILabel alloc] init];
    self.actor3Label.backgroundColor = [UIColor clearColor];
    self.actor3Label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.actor3Label.adjustsFontSizeToFitWidth = NO;
    self.actor3Label.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.actor3Label];
    
    self.actor4Label = [[UILabel alloc] init];
    self.actor4Label.backgroundColor = [UIColor clearColor];
    self.actor4Label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.actor4Label.adjustsFontSizeToFitWidth = NO;
    self.actor4Label.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.actor4Label];
    
    self.releaseLabel = [[UILabel alloc] init];
    self.releaseLabel.backgroundColor = [UIColor clearColor];
    self.releaseLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.releaseLabel.adjustsFontSizeToFitWidth = NO;
    self.releaseLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.releaseLabel];
    
    self.runtimeLabel = [[UILabel alloc] init];
    self.runtimeLabel.backgroundColor = [UIColor clearColor];
    self.runtimeLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.runtimeLabel.adjustsFontSizeToFitWidth = NO;
    self.runtimeLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.informationView addSubview:self.runtimeLabel];
    
    
    self.notesView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
    [self.mainScrollView addSubview:self.notesView];
    
    self.notesTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, 305.0f, 20.0f)];
    self.notesTitleLabel.text = NSLocalizedString(@"NOTES_TITLE", nil);
    [self setDefaultStylesForLabels:self.notesTitleLabel];
    self.notesTitleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
    self.notesTitleLabel.adjustsFontSizeToFitWidth = NO;
    self.notesTitleLabel.textColor = [UIColor colorWithHexString:@"191919"];
    [self.notesView addSubview:self.notesTitleLabel];
    
    self.notesLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.notesLabel];
    self.notesLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    self.notesLabel.adjustsFontSizeToFitWidth = NO;
    self.notesLabel.textColor = [UIColor colorWithHexString:@"787878"];
    [self.notesView addSubview:self.notesLabel];
    
    self.notesEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.notesEditButton.frame = CGRectMake(0.0f, 16.0f, 305.0f, 20.0f);
    self.notesEditButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0f];
    [self.notesEditButton setTitleColor:[UIColor colorWithHexString:@"787878"]];
    self.notesEditButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.notesEditButton setTitle:NSLocalizedString(@"NOTES_EDIT_TITLE", nil)];
    [self.notesView addSubview:self.notesEditButton];

    
    
}

- (void)setDefaultStylesForLabels:(UILabel*)label
{
    label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f];
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
